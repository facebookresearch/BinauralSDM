% Copyright (c) Facebook, Inc. and its affiliates.

function SRIR_data = create_SRIR_data(varargin)
% This function creates a struct that contains all the information
% regarding the analysis and auralization of a SRIR.
%
% - Input arguments: A pair of arguments with the format 'ArgumentName', 
% argumentvalue must be entered.
%       - fs: Sampling rate - integer - default: 48e3
%       - Room: Measured room name - string - default: 'NoRoom'
%       - SourcePos: Source position - string - default: 'S0'
%       - ReceiverPos: Receiver position - string - default: 'R0'
%       - Raw_RIR: Multichannel RIR - [N samples x M channels] - default:
%               [48e3 x 1] delta.
%       - P_RIR: Pressure RIR - [N samples x 1 channel] - default: 
%               [48e3 x 1] delta.
%       - DOA: Vector with DOA estimates in cartesian coordinates 
%               [N samples x 3] - default: [48e3 x 1] zeros.
%       - AlignDOA: Flag to indicate whether DOA must be aligned to force
%               the direct sound at az=0º, el=0º - integer - default: 1.
%       - DOASmooth: Window length for DOA estimates smoothing - integer -
%               default: 16.
%       - MicArray: Array model corresponding to the Raw_RIR. - string
%               ('Tetramic', 'Eigenmike', 'FRL_5cm' or 'FRL_10cm') - default: 'NoArray'
%       - ArrayGeometry: Mic positions in cartesian coordinates - 
%               [M channels x 3] float - default: [0 0 0].
%       - Method: SRIR analysis method - string - default: 'SDM'.
%       - Length: Desired length of RIR in seconds - float - default: 1.
%       - Split: Flag to indicate whether the rendered BRIR should be
%               splitted into DS, ER and LR when saving. - integer (0 or
%               1). Default: 1.
%       - MixingTime: Start of late reverb (in seconds) - float - 
%               default: 0.08.
%       - Denoise: Flag to indicate if Pressure RIR is denoised prior to
%               spatial analysis. - integer (0 or 1) - default: 1
%       - DenoiseLowFreq: Frequency of the lowest band for pressure RIR
%               denoising. - integer - default: 125
%       - DenoiseHighFreq: Frequency of the highest band for pressure RIR
%               denoising. - integer - default: 16000
%       - PlotDenoisedRIR: Flag for generation of figure with the original 
%               and denoised pressure RIR. - integer (0 or 1) - default: 0.
%       - OmniMicLag: Delay in samples between the raw and pressure RIR -
%               integer - default: 0.
%       - DS_idx: Sample index of the arrival of the direct sound - integer
%               - default: 0.
%       - DSonsetThreshold: Minimum amplitude of the RIR wrt maximum
%       absolute value used to detect the onset of the direct sound. -
%       float - default: 0.02.
%       - FilterRaw: Flag to indicate whether the raw RIR should be
%               bandpassed prior to spatial analysis - integer (0 or 1) - 
%               default: 0.
%       - FilterRawLowFreq: Low frequency cutoff for filtering of raw RIR -
%               integer - default: 200.
%       - FilterRawHighFreq: High frequency cutoff for filtering of raw RIR
%               - integer - default: 8000.
%       - Database_Path: Path to measured RIR database - string - default: 
%               '../../Data/RIRs/'
%
% Author: Sebastià V. Amengual (samengual@fb.com)
% Last Modified: 1/6/20
%
%
% TO-DO
%
%   An alternative to AP processing could be calculating a diffuseness
%   component and rendering a diffuse stream, similarly to SIRR (see
%   Merimaa and Pulkki 2005). Instead of using PIV, crosscorrelation values
%   between microphones when using TDOA could be used. Although preliminary
%   experiments were encouraging, this is not included in the present 
%   version of the code. The following parameters are currently unused:
%
%       - DiffFunc: Diffuseness function (from 0 to 1), estimated from
%       crosscorrelation of microphone pairs. Default = 0. 
%       - DiffN: Number of diffuse streams. Must be compatible with a
%       Lebedev grid. Default = 26.
%       - DiffWinLen: Length of the window for the creation of diffuse
%       streams. Default: 128
%       - DiffComponent: Flag to determine whether a diffuse component must 
%       be rendered. (1 or 0). Default: 0 (for backwards compatibility). 
%
%   Manipulation of the spatial information
%       - RandomDOA: Flag to indicate whether DOA must be randomized -
%               integer (0 or 1) - default: 0. Currently unused.
%

% Check input arguments
listNames = {'fs','Room','SourcePos','ReceiverPos','Raw_RIR','P_RIR','DOA',...
    'DOASmooth','RandomDOA','MicArray','ArrayGeometry','Method','Length',...
    'Split','MixingTime','Denoise','DenoiseLowFreq','DenoiseHighFreq','PlotDenoisedRIR',...
    'OmniMicLag','DS_idx','FilterRaw','FilterRawLowFreq','FilterRawHighFreq',...
    'Database_Path','DiffComponent','DiffWinLen','DiffN','DiffFunc','AlignDOA'};

for i = 1:2:length(varargin)
    if ~any(strcmpi(listNames,varargin{i}))
        error(['BRIR struct initialization: Unknown parameter ' varargin{i}]);
    end
end


% Initialize with default values
SRIR_data.fs = 48e3;
SRIR_data.SourcePos = 'S0';
SRIR_data.ReceiverPos = 'R0';
SRIR_data.Room = 'NoRoom';
SRIR_data.Raw_RIR = [1 ; zeros(SRIR_data.fs-1,1)];
SRIR_data.P_RIR = [1 ; zeros(SRIR_data.fs-1,1)];
SRIR_data.DOA = zeros(SRIR_data.fs,1);
SRIR_data.AlignDOA = 1;
SRIR_data.DOASmooth = 16;
SRIR_data.RandomDOA = 0;
SRIR_data.MicArray = 'NoArray';
SRIR_data.ArrayGeometry = [0 0 0];
SRIR_data.Method = 'SDM';
SRIR_data.Length = 1;
SRIR_data.Split = 1;
SRIR_data.MixingTime = 0.08;
SRIR_data.Denoise = 1;
SRIR_data.DenoiseLowFreq = 125;
SRIR_data.DenoiseHighFreq = 16000;
SRIR_data.PlotDenoisedRIR = 0;
SRIR_data.OmniMicLag = 0;
SRIR_data.DS_idx = 1;
SRIR_data.FilterRaw = 0;
SRIR_data.FilterRawLowFreq = 200;
SRIR_data.FilterRawHighFreq = 8000;
SRIR_data.Database_Path = '../../Data/RIRs/';
SRIR_data.DiffFunc = 0;
SRIR_data.DiffN = 26;
SRIR_data.DiffWinLen = 128;
SRIR_data.DiffComponent = 0;
SRIR_data.DSonsetThreshold = 0.02;

% Apply input arguments on BRIR_data struct
for i = 1:length(listNames)
    j = find(strcmpi(listNames{i},varargin));
    if any(j)
        % All numeric variables can be automatically assigned
        if isnumeric(varargin{j+1}) 
            eval(['SRIR_data.' listNames{i} ' = ' num2str(varargin{j+1}) ';'])
        % String variables are assigned one by one
        elseif strcmp(listNames{i},'SourcePos')
            SRIR_data.SourcePos = varargin{j+1};
        elseif strcmp(listNames{i},'ReceiverPos')
            SRIR_data.ReceiverPos = varargin{j+1};
        elseif strcmp(listNames{i},'Room')
            SRIR_data.Room = varargin{j+1};
        elseif strcmp(listNames{i},'MicArray')
            SRIR_data.MicArray = varargin{j+1};
        elseif strcmp(listNames{i},'Method')
            SRIR_data.Method = varargin{j+1};
        elseif strcmp(listNames{i},'Database_Path')
            SRIR_data.Database_Path = varargin{j+1};
        end
    else
        disp([listNames{i} ' initialized with default values']);
    end
end

SRIR_data.fs

% Build microphone array geometries
SRIR_data.ArrayGeometry = create_MicGeometry(SRIR_data.MicArray);


% Initializing data paths for the arrays
% Assigning the number of samples that the omnidirectional channel has over
% the raw signals. This delay will be corrected later in a circular shift during
% analysis
switch SRIR_data.MicArray
    case 'Eigenmike'
        SRIR_data.OmniMicLag = 25;
        disp(['OmniMicLag set automatically to 25 samples (Eigenmike)'])
    case 'NoArray'
        error('It seems that you have not selected a microphone array...');
end

SRIR_data = read_RIR(SRIR_data);
SRIR_data  = PreProcess_P_RIR(SRIR_data);
SRIR_data = PreProcess_Raw_RIR(SRIR_data);
