% Copyright (c) Facebook, Inc. and its affiliates.

function [SRIR_data, BRIR_data, HRIR_data, HRIR] = ...
    PreProcess_Synthesize_SDM_Binaural(SRIR_data, BRIR_data, HRIR_data)

disp('Started binaural SDM pre-processing');

switch upper(BRIR_data.HRTF_Type)
    case 'FRL_HRTF'
        % Restrict the HRTF directions to az=-180:180 degrees, el=-90:90 degrees
        HRIR_data.directions(HRIR_data.directions(:,1)>pi,1) = ...
            HRIR_data.directions(HRIR_data.directions(:,1)>pi,1) - 2*pi;

        [BRIR_data.HRTF_cartDir(:,1), BRIR_data.HRTF_cartDir(:,2), ...
            BRIR_data.HRTF_cartDir(:,3)] = sph2cart(HRIR_data.directions(:,1), ...
            HRIR_data.directions(:,2), HRIR_data.directions(:,3));

        BRIR_data.HRTF_cartDirNSTree = createns(BRIR_data.HRTF_cartDir);
    
        HRIR = cat(3, HRIR_data.left_HRTF, HRIR_data.right_HRTF);
        HRIR = permute(HRIR, [2, 3, 1]);

    case 'SOFA'
        % Restrict the HRTF directions to az=-180:180 degrees, el=-90:90 degrees
        HRIR_data.SourcePosition(HRIR_data.SourcePosition(:,1)>pi,1) = ...
            HRIR_data.SourcePosition(HRIR_data.SourcePosition(:,1)>pi,1) - 2*pi;  

        TempSourcePosition(:,1) = deg2rad(HRIR_data.SourcePosition(:,1));
        TempSourcePosition(:,2) = deg2rad(HRIR_data.SourcePosition(:,2));

        [BRIR_data.HRTF_cartDir(:,1), BRIR_data.HRTF_cartDir(:,2), ...
            BRIR_data.HRTF_cartDir(:,3)] = sph2cart(TempSourcePosition(:,1), ...
            TempSourcePosition(:,2), HRIR_data.SourcePosition(:,3));    

        HRIR = permute(HRIR_data.Data.IR, [3, 2, 1]);
    
    otherwise
        error('Invalid HRIR format "%s".', BRIR_data.HRTF_Type);
end

[DOA_rad(:,1), DOA_rad(:,2), DOA_rad(:,3)] = cart2sph( ...
    SRIR_data.DOA(:,1), SRIR_data.DOA(:,2), SRIR_data.DOA(:,3));
az = DOA_rad(:,1);
el = DOA_rad(:,2);

% ---- hack ----
% Sometimes you get NaNs from the DOA analysis
% Replace NaN directions with uniformly distributed random angle
az(isnan(az)) = pi-rand(size(az(isnan(az))))*2*pi;
el(isnan(el)) = pi/2-rand(size(el(isnan(el))))*pi;

az(az>pi) = az(az>pi) - 2*pi;
az(az<-pi) = az(az<-pi) + 2*pi;

el(el>pi/2) = el(el>pi/2) - pi;
el(el<-pi/2) = el(el<-pi/2) + pi;

[DOA_x, DOA_y, DOA_z] = sph2cart(az, el, 1);
SRIR_data.DOA = [DOA_x, DOA_y, DOA_z];

% Prepare filter bank for reverb compensation
BRIR_data.FilterBank_minFreq = 62.5;
BRIR_data.FilterBank_maxFreq = 20000;
BRIR_data.FilterBank_snfft = (BRIR_data.MixingTime+BRIR_data.TimeGuard)*BRIR_data.fs;

[BRIR_data.G,BRIR_data.FilterBank_g,BRIR_data.FilterBank_f1,BRIR_data.FilterBank_f2] = ...
    oneOver_n_OctBandFilter(2*BRIR_data.FilterBank_snfft, BRIR_data.BandsPerOctave, BRIR_data.fs, BRIR_data.FilterBank_minFreq , BRIR_data.FilterBank_maxFreq);

% Determine BRIR target length, if it has not been specified
if ~BRIR_data.Length
%     [T30, ~, ~] = getLundebyRT30(SRIR_data.P_RIR, SRIR_data.fs);
    [RT, ~] = getLundebyFOB(SRIR_data.P_RIR, SRIR_data.fs, ...
        BRIR_data.BandsPerOctave, BRIR_data.EqTxx);
    RT = max(RT(BRIR_data.BandsPerOctave+1:end-BRIR_data.BandsPerOctave-1)); % ignore highest and lowest octave
%     RT = max(RT);
    
    % remaining direct sound onset + estimated RT
    BRIR_data.Length = SRIR_data.DS_idx / SRIR_data.fs + RT;
    fprintf('Chose %.2f s BRIR target length based on SRIR T30 analysis.\n', ...
        BRIR_data.Length);
end

% Extend SRIR data since it will be required during BRIR synthesis
BRIR_length = ceil(BRIR_data.Length * SRIR_data.fs);
if BRIR_length > length(SRIR_data.P_RIR)
    SRIR_data.DOA = [SRIR_data.DOA; repmat([1, 0, 0], BRIR_length - length(SRIR_data.DOA), 1)];
    SRIR_data.P_RIR(end:BRIR_length) = 0;
end

fprintf('\n');

end
