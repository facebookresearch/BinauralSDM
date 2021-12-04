% Copyright (c) Facebook, Inc. and its affiliates.

function SaveBRIR(BRIR_data, BRIR_DS, BRIR_DSER, BRIR_ER, BRIR_LR, ang)
% This function saves the BRIR dataset generated from the re-synthesis
% through SDM. 
% Input arguments:
%   - BRIR_data: Struct containing BRIR information (see create_BRIR_data).
%   - BRIR_DS: Direct sound part of the BRIR.
%   - BRIR_DSER: Early part of the BRIR (containing DS).
%   - BRIR_ER: Early reflections (without direct sound).
%   - BRIR_LR: Angle independent late reverb tail.
%   - ang: 
%
%   Author: Sebastià V. Amengual
%   Last modified: 12/04/2021

% create output directory (ignore if it already exists)
[~, ~] = mkdir(BRIR_data.DestinationPath);

attenuation = db2mag(BRIR_data.Attenuation);
max_value = max(max(abs(BRIR_DS)))/attenuation;
if max_value > 1
    error('The exported BRIRs are clipping! - The max value is %f.', max_value);
end

base_name = sprintf('az%del%d', ang(1), ang(2));

if BRIR_data.ExportDSERcFlag
    audiowrite(fullfile(BRIR_data.DestinationPath, [base_name, '.wav']), ...
        BRIR_DSER ./ attenuation, BRIR_data.fs, 'BitsPerSample', 32);
end

if BRIR_data.ExportDSERsFlag
    audiowrite(fullfile(BRIR_data.DestinationPath, [base_name, '_DS.wav']), ...
        BRIR_DS ./ attenuation, BRIR_data.fs, 'BitsPerSample', 32);
    audiowrite(fullfile(BRIR_data.DestinationPath, [base_name, '_ER.wav']), ...
        BRIR_ER ./ attenuation, BRIR_data.fs, 'BitsPerSample', 32);
end

if ~isempty(BRIR_LR)
    audiowrite(fullfile(BRIR_data.DestinationPath, 'late_reverb.wav'), ...
        BRIR_LR ./ attenuation, BRIR_data.fs, 'BitsPerSample', 32);
end
