% Copyright (c) Facebook, Inc. and its affiliates.

function Save_BRIR_sofa(BRIR_data, BRIR_DSER, BRIR_LR)
% This function saves the BRIR dataset generated from the re-synthesis
% through SDM in the form of a SOFA-file.

% Input arguments:
%   - BRIR_data: Struct containing BRIR information (see create_BRIR_data).
%   - BRIR_DSER: Early part of the BRIR (containing DS).
%   - BRIR_LR: Angle independent late reverb tail.
%
%   Author: Hannes Helmholz
%   Last modified: 08/26/2022

Initialize_SOFA();

% create output directory (ignore if it already exists)
[~, ~] = mkdir(BRIR_data.DestinationPath);

% combine direct sound, early reflections and late reverb
BRIR = repmat(BRIR_LR, [1, 1, size(BRIR_DSER, 3)]);
BRIR(1:size(BRIR_DSER, 1), :, :) = BRIR(1:size(BRIR_DSER, 1), :, :) + BRIR_DSER;
BRIR = BRIR ./ db2mag(BRIR_data.Attenuation);

max_value = max(abs(BRIR), [], 'all');
if max_value > 1
    error('The exported BRIRs are clipping! - The max value is %f.', max_value);
end

% generate struct
sofa_struct = SOFAgetConventions('SingleRoomSRIR');

% fill SOFA data
[~, n_receivers, n_measurements] = size(BRIR);
sofa_struct.Data.IR = permute(BRIR, [3, 2, 1]);
sofa_struct.Data.SamplingRate = BRIR_data.fs;
sofa_struct.Data.Delay = zeros([1, n_measurements]);
sofa_struct.Data.Delay = zeros([1, n_receivers]);
sofa_struct.GLOBAL_ListenerShortName = BRIR_data.HRTF_Subject;
sofa_struct.ListenerPosition = repmat( ... % this is not an accurate position
    sofa_struct.ListenerPosition, [n_measurements, 1]);
sofa_struct.ListenerView = BRIR_data.Directions;
sofa_struct.ListenerView(:, 3) = 0; % add radius
sofa_struct.ListenerView_Type = 'spherical';
sofa_struct.ListenerView_Units = 'degree, degree, metre';
if contains(sofa_struct.GLOBAL_ListenerShortName, 'KU100', 'IgnoreCase', true)
    sofa_struct.ReceiverPosition = [0, -0.0875, 0; 0, 0.0875, 0];
    sofa_struct.ReceiverPosition_Type = 'cartesian';
    sofa_struct.ReceiverPosition_Units = 'metre';
else
    error('Unknown ear positions for listener "%s".', ...
        sofa_struct.GLOBAL_ListenerShortName);
end
sofa_struct.ReceiverView = repmat(sofa_struct.ReceiverView, [n_receivers, 1]);
sofa_struct.ReceiverUp = repmat(sofa_struct.ReceiverUp, [n_receivers, 1]);
sofa_struct.SourcePosition = repmat( ... % this is not an accurate position
    [1, 0, 0], [n_measurements, 1]);
sofa_struct.SourcePosition_Type = 'cartesian';
sofa_struct.SourcePosition_Units = 'metre';
sofa_struct.SourceView = [-1, 0, 0];
sofa_struct.SourceView_Type = 'cartesian';
sofa_struct.SourceView_Units = 'metre';

% % evaluate SOFA comformity
% sofa_struct = SOFAupdateDimensions(sofa_struct, 'verbose', true);

SOFAsave(fullfile(BRIR_data.DestinationPath, 'BRIR_full.sofa'), sofa_struct);
