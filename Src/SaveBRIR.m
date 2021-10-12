% Copyright (c) Facebook, Inc. and its affiliates.

function SaveBRIR(SRIR_data, BRIR_data, DS_BRIR, early_BRIR, ER_BRIR, late_BRIR, ang)
% This function saves the BRIR dataset generated from the re-synthesis
% through SDM. 
% Input arguments:
%   - SRIR_data: Struct containing all the SRIR information (see
%   create_SRIR_data)
%   - BRIR_data: Struct containing BRIR information (see create_BRIR_data)
%   - DS_BRIR: Direct sound part of the BRIR
%   - early_BRIR: Early part of the BRIR (containing DS)
%   - ER_BRIR: Early reflections (without direct sound).
%   - late_BRIR: Angle independent late reverb tail.
%
%   Author: Sebastià V. Amengual
%   Last modified: 10/12/21

Save_Path = fullfile(BRIR_data.DestinationPath, ...
    strrep(BRIR_data.HRTF_Subject, ' ', '_'), ...
    sprintf('%s_%s_%s', SRIR_data.Room, SRIR_data.SourcePos, SRIR_data.ReceiverPos), ...
    BRIR_data.RenderingCondition);

% create output directory (ignore if it already exists)
[~, ~] = mkdir(Save_Path);

attenuation = db2mag(BRIR_data.Attenuation);
max_value = max(max(abs(DS_BRIR)))/attenuation;
if max_value > 1
    error('The exported BRIRs are clipping! - The max value is %f.', max_value);
end

audiowrite(fullfile(Save_Path, sprintf('az%del%d.wav', ang(1), ang(2))), ...
    early_BRIR./attenuation, BRIR_data.fs, 'BitsPerSample', 32);
audiowrite(fullfile(Save_Path, sprintf('az%del%d_DS.wav', ang(1), ang(2))), ...
    DS_BRIR./attenuation, BRIR_data.fs, 'BitsPerSample', 32);
audiowrite(fullfile(Save_Path, sprintf('az%del%d_ER.wav', ang(1), ang(2))), ...
    ER_BRIR./attenuation, BRIR_data.fs, 'BitsPerSample', 32);
if ~isempty(late_BRIR)
    audiowrite(fullfile(Save_Path, 'late_reverb.wav'), ...
        late_BRIR./attenuation, BRIR_data.fs, 'BitsPerSample', 32);
end

end
