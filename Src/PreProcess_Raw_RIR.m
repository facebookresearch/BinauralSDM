% Copyright (c) Facebook, Inc. and its affiliates.

function SRIR_data = PreProcess_Raw_RIR(SRIR_data)
% This function pre-processes the raw RIR (containing time differences) to 
% accommodate the parameters specified in SRIR_data. This includes time
% cropping and frequency filtering.
%
% Author: Sebastià V. Amengual
% Last modified: 11/17/2021

% Filtering raw signals
if SRIR_data.FilterRaw
    norm_flow = SRIR_data.FilterRawLowFreq / (SRIR_data.fs/2);
    norm_fhigh = SRIR_data.FilterRawHighFreq / (SRIR_data.fs/2);
    [b, a] = butter(6, [norm_flow, norm_fhigh]);  
    SRIR_data.Raw_RIR = filtfilt(b, a, SRIR_data.Raw_RIR);
end

end
