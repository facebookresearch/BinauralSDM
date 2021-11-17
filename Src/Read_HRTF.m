% Copyright (c) Facebook, Inc. and its affiliates.

function HRTF_data = Read_HRTF(BRIR_data)

if strcmp(BRIR_data.HRTF_Type, 'FRL_HRTF')
    HRTF_data = load(BRIR_data.HRTF_Path);
    HRTF_data = HRTF_data.hrtf_data;
elseif strcmp(BRIR_data.HRTF_Type, 'SOFA')
    HRTF_data = SOFAload(BRIR_data.HRTF_Path);
else
    error('HRTF format not recognized - Valid options: FRL_HRTF, SOFA.')
end