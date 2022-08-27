% Copyright (c) Facebook, Inc. and its affiliates.

function HRTF_data = Read_HRTF(BRIR_data)

fprintf('Loading HRIR dataset "%s" ... ', BRIR_data.HRTF_Path);

switch upper(BRIR_data.HRTF_Type)
    case 'FRL_HRTF'
        HRTF_data = load(BRIR_data.HRTF_Path);
        HRTF_data = HRTF_data.hrtf_data;
        
	case 'SOFA'
        Initialize_SOFA();
        HRTF_data = SOFAload(BRIR_data.HRTF_Path);
    
    otherwise
        fprintf('\n');
        error('Invalid HRIR format "%s".', BRIR_data.HRTF_Type);
end

fprintf('done.\n\n');
 
end
