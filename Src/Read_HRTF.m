% Copyright (c) Facebook, Inc. and its affiliates.

function HRTF_data = Read_HRTF(BRIR_data)

fprintf('Loading HRIR dataset "%s" ... ', BRIR_data.HRTF_Path);

if strcmp(BRIR_data.HRTF_Type, 'FRL_HRTF')
    HRTF_data = load(BRIR_data.HRTF_Path);
elseif strcmp(BRIR_data.HRTF_Type, 'SOFA')
    try
        SOFAstart;
    catch ME
        if strcmp(ME.identifier, 'MATLAB:UndefinedFunction')
            warning('MATLAB:UndefinedFunction', ['SOFA library not found in MATLAB path.\n'...
                'Please download the API from https://github.com/sofacoustics/API_MO\n',...
                'and link to the folder in the opened file dialog.']);

            % show file dialog to link to API folder
            SOFA_dir = uigetdir('', 'Select SOFA API root folder');

            % add directory to path
            fprintf('Adding "%s" to MATLAB path.\n', SOFA_dir); 
            addpath(genpath(SOFA_dir));

            % now run SOFAstart (hopefully)
            SOFAstart;
        else
            rethrow(ME);
        end
    end 
    
    HRTF_data = SOFAload(BRIR_data.HRTF_Path);
else
    error('HRTF format not recognized - Valid options: FRL_HRTF, SOFA.')
end

fprintf('done.\n\n');
 
end
