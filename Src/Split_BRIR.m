% Copyright (c) Facebook, Inc. and its affiliates.

function [BRIR_DSER, BRIR_LR, BRIR_DS, BRIR_ER] = Split_BRIR( ...
    BRIR_early, BRIR_late, mixtime, fs, wlength)

% This function splits a BRIR into its various parts for separate
% auralization of direct sound, early reflections and late reverberation.
% The separation between different BRIR sections is done using a Hann
% window to avoid artifacts.

% Inputs: 
%       - BRIR_early: Binaural room impulse response to be split
%       - BRIR_late: Ref. pressure impulse response (only to detect direct sound)
%       - mixtime: time where the fadeout-fadein hann windows intersect (in seconds).
%       - fs: sampling rate of the impulse responses
%       - wlength: duration of the hann window
% Outputs: 
%       - BRIR_DSER: Early part of the BRIR up to the mixing time
%       - BRIR_LR: Late part of the BRIR (late reverberation)
%       - BRIR_DS: Direct sound (first 256 samples with decaying window)
%       - BRIR_ER: from sample 257 to mixing time (only early reflections)
%
% Author: Sebastia V. Amengual
% Last modified: 11/19/2021
%
% To-Do:    - More informed method to separate DS and ER, rather than just
%               windowing after 256 samples

% Parameters for the extraction of direct sound
DS_LEN = 256;
DS_WLENGTH = 32;

disp('Started splitting of BRIR');

% Create a Hann window for the crossfade between DS and ER and LR
window_hann_DS = hann(DS_WLENGTH);
window_hann_LR = hann(wlength);

% Create the windows
window_DSER = [ones(mixtime*fs-wlength/2,1); window_hann_LR(wlength/2+1:end)];

window_DS = [ones(DS_LEN-DS_WLENGTH/2,1); window_hann_DS(DS_WLENGTH/2+1:end)];
fprintf(['Window for direct sound of %d samples ', ...
    '(incl. %d samples fade-out)\n'], ...
    length(window_DS), DS_WLENGTH/2);

window_ER = [zeros(DS_LEN-DS_WLENGTH/2,1); window_hann_DS(1:DS_WLENGTH/2); ...
    window_DSER(DS_LEN+1:end)];
fprintf(['Window for early reflections of %d samples ', ...
    '(incl. %d samples fade-in, %d samples fade-out)\n'], ...
    length(window_ER), DS_WLENGTH/2, wlength/2);

window_LR = [zeros(mixtime*fs-wlength/2,1); window_hann_LR(1:wlength/2)];
window_LR = [window_LR ; ones(length(BRIR_late)-length(window_LR), 1)];
fprintf(['Window for late reverberation of %d samples ', ...
    '(incl. %d samples fade-in)\n'], length(window_LR), wlength/2);

% Extract the BRIRs
BRIR_DSER = BRIR_early(1:length(window_DSER),:,:) .* window_DSER;
BRIR_DS = BRIR_early(1:length(window_DS),:,:) .* window_DS;
BRIR_ER = BRIR_early(1:length(window_ER),:,:) .* window_ER;
BRIR_LR = BRIR_late .* window_LR;

% % plot windows
% fig = figure('NumberTitle', 'off', 'Name', 'Windows');
% fig.Position(3) = fig.Position(3) * 2;
% plot(window_DSER, 'LineWidth', 5);
% hold on;
% plot(window_DS, 'LineWidth', 2);
% plot(window_ER, 'LineWidth', 2);
% plot(window_LR, 'LineWidth', 2);
% legend({'DSER', 'DS', 'ER', 'LR'}, 'Location', 'East');
% xlim([0, length(window_DSER) * 1.1]);
% ylim([-.1, 1.1]);
% xlabel('Samples');
% ylabel('Amplitude');
% grid on;

fprintf('\n');

end
