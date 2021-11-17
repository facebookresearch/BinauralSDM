% Copyright (c) Facebook, Inc. and its affiliates.

function [SRIR_data, BRIR_data, HRTF_data, HRTF_TransL, HRTF_TransR] = PreProcess_Synthesize_SDM_Binaural(SRIR_data, BRIR_data, HRTF_data)


[DOA_rad(:,1), DOA_rad(:,2), DOA_rad(:,3)] = cart2sph(SRIR_data.DOA(:,1), SRIR_data.DOA(:,2), SRIR_data.DOA(:,3));

if strcmp(BRIR_data.HRTF_Type,'FRL_HRTF')
    % Restrict the HRTF directions to az=-180:180 degrees, el=-90:90 degrees
    HRTF_data.directions(HRTF_data.directions(:,1)>pi,1) = HRTF_data.directions(HRTF_data.directions(:,1)>pi,1) - 2*pi;

    HRTF_TransL = HRTF_data.left_HRTF';
    HRTF_TransR = HRTF_data.right_HRTF';

    [BRIR_data.HRTF_cartDir(:,1), BRIR_data.HRTF_cartDir(:,2), BRIR_data.HRTF_cartDir(:,3)] = ...
        sph2cart(HRTF_data.directions(:,1), HRTF_data.directions(:,2), HRTF_data.directions(:,3));

    BRIR_data.HRTF_cartDirNSTree = createns(BRIR_data.HRTF_cartDir);
elseif strcmp(BRIR_data.HRTF_Type,'SOFA')
    % Restrict the HRTF directions to az=-180:180 degrees, el=-90:90 degrees
    HRTF_data.SourcePosition(HRTF_data.SourcePosition(:,1)>pi,1) = HRTF_data.SourcePosition(HRTF_data.SourcePosition(:,1)>pi,1) - 2*pi;  
    
    TempSourcePosition(:,1) = deg2rad(HRTF_data.SourcePosition(:,1));
    TempSourcePosition(:,2) = deg2rad(HRTF_data.SourcePosition(:,2));

    [BRIR_data.HRTF_cartDir(:,1), BRIR_data.HRTF_cartDir(:,2), BRIR_data.HRTF_cartDir(:,3)] = ...
        sph2cart(TempSourcePosition(:,1), TempSourcePosition(:,2), HRTF_data.SourcePosition(:,3));    
        
    HRTF_TransL = squeeze(HRTF_data.Data.IR(:,1,:))';
    HRTF_TransR = squeeze(HRTF_data.Data.IR(:,2,:))';   
end

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

