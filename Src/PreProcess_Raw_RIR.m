% Copyright (c) Facebook, Inc. and its affiliates.

function SRIR_data = PreProcess_Raw_RIR(SRIR_data)
% This function pre-processes the raw RIR (containing time differences) to 
% accommodate the parameters specified in SRIR_data. This includes time
% cropping and frequency filtering.
%
% Author: Sebastià V. Amengual
% Last modified: 12/18/2018


% Cropping the Raw RIRs (but not removing leading zeros due to DOA
% estimation requirements)
SRIR_data.Raw_RIR = SRIR_data.Raw_RIR(1:SRIR_data.DS_idx+SRIR_data.fs*SRIR_data.Length-1,:);

% Filtering raw signals
if SRIR_data.FilterRaw == 1
    norm_flow = SRIR_data.FilterRawLowFreq/(SRIR_data.fs/2);
    norm_fhigh = SRIR_data.FilterRawHighFreq/(SRIR_data.fs/2);
    [b,a]=butter(6,[norm_flow norm_fhigh]);  
    SRIR_data.Raw_RIR = filtfilt(b,a,SRIR_data.Raw_RIR);
end
