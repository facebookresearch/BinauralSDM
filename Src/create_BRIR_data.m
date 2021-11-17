% Copyright (c) Facebook, Inc. and its affiliates.

function BRIR_data = create_BRIR_data (varargin)
%
%       Input parameters:
%       - fs: Sampling rate - integer - default: 48e3
%       - HRTF_Subject: Name/ID of the subject's HRTF used for re-synthesis
%               - string - default: 'KEMAR'
%       - HRTF_Type: Format of HRTF for re-synthesis string - default 
%               'SOFA'. Other options: 'FRL_HRTF'
%       - HRTF_Path: File name of the HRTF used for re-synthesis -
%               string - default: '../../Data/HRIRs/KU100_HRIR_FULL2DEG_Koeln.sofa'.
%       - BRIR_DestinationPath: Path to the BRIR database for saving -
%       string - default: '../../Data/Rendered_BRIRs/'.
%       - Length: Desired length of RIR in seconds - float - default: 1.
%       - MixingTime: Start of late reverb (in seconds) - float - 
%               default: 0.08.
%       - AzOrient: Vector with the azimuth angles to render [N x 1] -
%       float - default: (-180:1:180)'.
%       - ElOrient: Vector with the azimuth angles to render [N x 1] -
%       float - default: (-90:5:90)'.
%       - Attenuation: Attenuation factor on the rendered BRIR (in dB) -
%       float - default: 0.
%       - TimeGuard: Time (in seconds) greater than the propagation time 
%       in the impulse response. It is needed to make sure that the early
%       reflections are synthesized up to the mixing time correctly. - 
%       default: 0.01.
%       - RenderingCondition: Optional string to describe some rendering
%       options. This will create a folder in which renderings are saved 
%       and is only used for naming purposes during saving.
%       - QuantizeDOAFlag: Flag to indicate whether DOA information must me
%       quantized. - default: 0.
%       - DOADirections: Number of directions to quantize DOA information.
%       This is only relevant if QuantizeDOAFlag == 1 - default: 50. 
% 
% Author: Sebastia V. Amengual (samengual@fb.com)
% Last modified: 11/17/2021
% 
% To-Do:    
%   - Spectral equalization options: If a reference measured BRIR is
%   available it could be used to implement spectral equalization.
%   - Split (unused): Flag to indicate whether the rendered BRIR should be
%   splitted into DS, ER and LR when saving. - integer (0 or 1). Default: 1.
%   In subsequent versions this might be updated to customize saving.


% Check input arguments
listNames = {'fs','HRTF_Subject','HRTF_Type','HRTF_Path',...
    'DestinationPath','Length','Split','MixingTime','AzOrient','ElOrient',...
    'RenderingCondition','Attenuation','QuantizeDOAFlag','DOADirections','BandsPerOctave','EqTxx'};

for i = 1:2:length(varargin)
    if ~any(strcmpi(listNames,varargin{i}))
        error(['BRIR struct initialization: Unknown parameter ' varargin{i}]);
    end
end

% These parameters to be defined
%BRIR_data.Orientation =
%BRIR_data.BRIR_TimeData = 

%BRIR_data.FrontalEqMethod = 
%BRIR_data.ReferenceBRIR = 

%BRIR_data.ReverbTailMethod = 
%BRIR_data.ReverbTailEqMethod = 

%BRIR_data.TimeFreqEqFilterLeft =
%BRIR_data.TimeFreqEqFilterRight =

BRIR_data.fs = 48e3;

BRIR_data.HRTF_Type = 'SOFA';
BRIR_data.HRTF_Path = '..\..\Data\HRIRs\KU100_HRIR_FULL2DEG_Koeln.sofa';

BRIR_data.DestinationPath = '../../Data/Rendered_BRIRs/';
BRIR_data.AzOrient = (-180:1:180)';
BRIR_data.ElOrient = (-90:5:90)';

BRIR_data.MixingTime = 0.08;
BRIR_data.Split = 1;
BRIR_data.Length = 1;
BRIR_data.TimeGuard = 0.01;

BRIR_data.Attenuation = 0;

BRIR_data.RenderingCondition = 'Original';

BRIR_data.BandsPerOctave = 3;
BRIR_data.EqTxx = 30;

BRIR_data.QuantizeDOAFlag = 0;
BRIR_data.DOADirections = 50;

% Apply input arguments on BRIR_data struct
for i = 1:length(listNames)
    j = find(strcmpi(listNames{i},varargin));
    if any(j)
        % All numeric variables can be automatically assigned
        if isnumeric(varargin{j+1}) && numel(varargin{j+1})<=1
            eval(['BRIR_data.' listNames{i} ' = ' num2str(varargin{j+1}) ';']);
        % String variables are assigned one by one
        elseif strcmp(listNames{i},'HRTF_Subject')
            BRIR_data.HRTF_Subject = varargin{j+1};
        elseif strcmp(listNames{i},'HRTF_Type')
            BRIR_data.HRTF_Type = varargin{j+1};
        elseif strcmp(listNames{i},'HRTF_Path')
            BRIR_data.HRTF_Path = varargin{j+1};
        elseif strcmp(listNames{i},'DestinationPath')
            BRIR_data.DestinationPath = varargin{j+1};
        elseif strcmp(listNames{i},'RenderingCondition')
            BRIR_data.RenderingCondition = varargin{j+1};
        elseif strcmp(listNames{i},'AzOrient')
            BRIR_data.AzOrient = varargin{j+1};
        elseif strcmp(listNames{i},'ElOrient')
            BRIR_data.ElOrient = varargin{j+1};
        end
    else
        disp([listNames{i} ' initialized with default values']);
    end
end

[rot_az, rot_el] = meshgrid(BRIR_data.AzOrient,BRIR_data.ElOrient);
BRIR_data.Directions = [reshape(rot_az,numel(rot_el),1) reshape(rot_el,numel(rot_az),1)];
