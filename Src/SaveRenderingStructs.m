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
%   Last modified: 7/11/19

Save_Path = [BRIR_data.DestinationPath  regexprep(BRIR_data.HRTF_Subject,' ','_'), filesep SRIR_data.Room '_' SRIR_data.SourcePos '_' SRIR_data.ReceiverPos];

if ~exist([Save_Path filesep BRIR_data.RenderingCondition filesep], 'dir')
    mkdir([Save_Path filesep BRIR_data.RenderingCondition filesep]);
end

save([Save_Path filesep BRIR_data.RenderingCondition filesep 'SRIR_data.mat'],'SRIR_data');
save([Save_Path filesep BRIR_data.RenderingCondition filesep 'BRIR_data.mat'],'BRIR_data');

end
