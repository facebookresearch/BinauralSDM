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
%   Last modified: 10/12/21

Save_Path = fullfile(BRIR_data.DestinationPath, ...
    strrep(BRIR_data.HRTF_Subject, ' ', '_'), ...
    sprintf('%s_%s_%s', SRIR_data.Room, SRIR_data.SourcePos, SRIR_data.ReceiverPos), ...
    BRIR_data.RenderingCondition);

% create output directory (ignore if it already exists)
[~, ~] = mkdir(Save_Path);

save(fullfile(Save_Path, 'SRIR_data.mat'), 'SRIR_data');
save(fullfile(Save_Path, 'BRIR_data.mat'), 'BRIR_data');

end
