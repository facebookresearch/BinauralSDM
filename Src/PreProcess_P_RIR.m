% Copyright (c) Facebook, Inc. and its affiliates.

function SRIR_data = PreProcess_P_RIR(SRIR_data)
% This function pre-processes the pressure RIR prior to SDM analysis.
% Pre-processing includes denoising by decay extrapolation, cropping RIR to
% selected time and circular shifting according to the microphone array
% encoding delay.
% 
% Dependencies: Denoising algorithm from Cabrera et al. included in AARAE
%
% Author: Sebastia V. Amengual
% Last modified: 4/19/19


% Denoising Pressure RIR
if SRIR_data.Denoise == 1
    try
        SRIR_data.P_RIR = denoise_RIR(SRIR_data.P_RIR,SRIR_data.fs,...
            SRIR_data.DenoiseHighFreq,SRIR_data.DenoiseLowFreq,SRIR_data.PlotDenoisedRIR);
    catch
        try 
            SRIR_data.DenoiseHighFreq = 8000;
            SRIR_data.DenoiseLowFreq = 125;
            SRIR_data.P_RIR = denoise_RIR(SRIR_data.P_RIR,SRIR_data.fs,...
                SRIR_data.DenoiseHighFreq,SRIR_data.DenoiseLowFreq,SRIR_data.PlotDenoisedRIR);
            disp('The pressure RIR could not be denoised with the user defined parameters. Trying with LowFreq=125Hz, HigFreq=8kHz')
        catch
            disp('The pressure RIR could not be denoised. It might be too short, have not enough SNR or be already denoised')
        end
    end
end

% Circular shifting
SRIR_data = shift_P_RIR(SRIR_data);

% Find index of direct sound (-34dB to highest value)
%SRIR_data.DS_idx = find(abs(SRIR_data.P_RIR)>0.02*max(abs(SRIR_data.P_RIR)),1,'first');
SRIR_data.DS_idx = findDirect(SRIR_data.P_RIR);

SRIR_data = getDSonset(SRIR_data);

% Cropping RIR to desired length
SRIR_data.P_RIR = SRIR_data.P_RIR(SRIR_data.DSonset:SRIR_data.DSonset+SRIR_data.fs*SRIR_data.Length-1,1);