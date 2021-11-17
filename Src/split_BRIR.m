% Copyright (c) Facebook, Inc. and its affiliates.

function [early_BRIR, late_BRIR, DS_BRIR, ER] = split_BRIR(BRIR_TimeData, BRIR_full, mixtime, fs, wlength)
% This function splits a BRIR into its various parts for separate
% auralization of direct sound, early reflections and late reverberation.
% The separation between different BRIR sections is done using a Hann
% window to avoid artifacts.
% 
% Inputs: 
%       - BRIR: Binaural room impulse response to be split
%       - P_IR: Ref. pressure impulse response (only to detect direct sound)
%       - mixtime: time where the fadeout-fadein hann windows intersect (in seconds).
%       - fs: sampling rate of the impulse responses
%       - wlength: duration of the hann window
% Outputs: 
%       - early_BRIR: Early part of the BRIR up to the mixing time
%       - late_BRIR: Late part of the BRIR (late reverberation)
%       - DS_BRIR: Direct sound (first 256 samples with decaying window)
%       - ER: from sample 257 to mixing time (only early reflections)
%
% Author: Sebastia V. Amengual
% Last modified: 11/17/2021
%
% To-Do:    - More informed method to separate DS and ER, rather than just
%               windowing after 256 samples

% Create a Hann window for the crossfade between ER and Late Reverb.
hann_window = hann(wlength);

% Create the window to retrieve DS+ER
window_ER = [ones(mixtime*fs-wlength/2,1); hann_window(wlength/2+1:end)];

% Create the window to retrieve LR
window_LR = [zeros(mixtime*fs-wlength/2,1); hann_window(1:wlength/2)];
window_LR = [window_LR ; ones(length(BRIR_full)-length(window_LR),1)];

% Retrieve the DS+ER BRIR
early_BRIR = BRIR_TimeData(1:length(window_ER),:,:).*window_ER;

% Retrieve the late reverb BRIR
late_BRIR = BRIR_full.*window_LR;

% Parameters for the extraction of direct sound
DS_wlength = 256;
DS_xfade = 32;
DS_hann = hann(DS_xfade);

% Create window to retrieve direct sound
window_DS = [ones(DS_wlength-DS_xfade/2,1);DS_hann(DS_xfade/2+1:end)];
%plot(window_DS)
%hold on
%plot(window_ER)
%plot(window_LR)

% Retrieve direct sound
DS_BRIR = BRIR_TimeData(1:length(window_DS),:,:).*window_DS;

% Create window to extract early reflections (without direct sound)
window_ER_noDS = [zeros(DS_wlength-DS_xfade/2,1);DS_hann(1:DS_xfade/2)];
window_ER_noDS = [window_ER_noDS; window_ER(DS_wlength+1:end)];

% Retrieve early reflections (without direct sound)
ER = BRIR_TimeData(1:length(window_ER_noDS),:,:).*window_ER_noDS;
