% Copyright (c) Facebook, Inc. and its affiliates.

function Initialize_SOFA()

try
    SOFAstart();
catch ME
    if strcmp(ME.identifier, 'MATLAB:UndefinedFunction')
        warning('MATLAB:UndefinedFunction', ...
            ['SOFA library not found in MATLAB path.\n'...
            'Please download the API from https://github.com/sofacoustics/API_MO\n',...
            'and link to the folder in the opened file dialog.']);

        % show file dialog to link to API folder
        SOFA_dir = uigetdir('', 'Select SOFA API root folder');

        % add directory to path
        fprintf('Adding "%s" to MATLAB path.\n', SOFA_dir); 
        addpath(genpath(SOFA_dir));

        % now run SOFAstart (hopefully)
        SOFAstart();
    else
        rethrow(ME);
    end
end

end
