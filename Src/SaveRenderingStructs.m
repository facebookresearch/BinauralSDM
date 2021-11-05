% Copyright (c) Facebook, Inc. and its affiliates.

function SaveRenderingStructs(SRIR_data, BRIR_data)
% This function saves the SRIR_data and BRIR_data structs in the same path
% as the renderings
% Input arguments:
%   - SRIR_data: Struct containing all the SRIR information (see
%   create_SRIR_data)
%   - BRIR_data: Struct containing BRIR information (see create_BRIR_data)
%
%   Author: Sebastià V. Amengual
%   Last modified: 11/05/2021

% create output directory (ignore if it already exists)
[~, ~] = mkdir(BRIR_data.DestinationPath);

save(fullfile(BRIR_data.DestinationPath, 'SRIR_data.mat'), 'SRIR_data');
save(fullfile(BRIR_data.DestinationPath, 'BRIR_data.mat'), 'BRIR_data');

end
