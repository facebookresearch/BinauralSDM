% Copyright (c) Facebook, Inc. and its affiliates.

function SRIR_data = getDSonset(SRIR_data)

SRIR_data.DSonset = find(abs(SRIR_data.P_RIR)>SRIR_data.DSonsetThreshold*abs(SRIR_data.P_RIR(SRIR_data.DS_idx)),1,'first');

if SRIR_data.DSonset == 1
    warning(['The onset of the direct sound could not be estimated. Please adjust the parameter SRIR_data.DSonsetThreshold according to the SNR of your RIR.'])
end


    