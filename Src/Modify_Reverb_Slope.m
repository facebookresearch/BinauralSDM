% Copyright (c) Facebook, Inc. and its affiliates.

function BRIR_mod = Modify_Reverb_Slope(BRIR_data, BRIR, Plot_data)
% This function decomposes a BRIR into several bands and modifies the decay
% slope of each band according to the input parameters.
%
%   Input parameters:
%       - BRIR_data: Struct containing BRIR configuration data.
%       - BRIR_TimeData: Binaural room impulse response to be modified.
%       - Plot_data: Struct containing Plot configuration data - optional.
%   Output parameters:
%       - BRIR_mod: Binaural room impulse response with the modified reverb.
%
%   Author: Sebastia V. Amengual
%   Last modified: 11/17/2021

PLOT_FMT = 'pdf';

if nargin < 3; Plot_data = []; end

% Need to regenerate the filterbank in case the corrected BRIR is longer
% than the mixing time (special case for the late reverb tail).
if length(BRIR) > length(BRIR_data.FilterBank_g)
    BRIR_data.FilterBank_snfft = length(BRIR);
    [BRIR_data.G, BRIR_data.FilterBank_g, BRIR_data.FilterBank_f1, BRIR_data.FilterBank_f2] = ...
        oneOver_n_OctBandFilter(2*BRIR_data.FilterBank_snfft, ...
        BRIR_data.BandsPerOctave, BRIR_data.fs, ...
        BRIR_data.FilterBank_minFreq , BRIR_data.FilterBank_maxFreq);
end

% Regularize RT modification
if BRIR_data.RTModRegFreq && ~isfield(BRIR_data, 'DesiredT30_unlimited')
    BRIR_data.DesiredT30_unlimited = BRIR_data.DesiredT30;
    % limit modification to not amplify
    % hf_bands = BRIR_data.RTFreqVector > 9e3;
    % BRIR_data.DesiredT30(hf_bands) = min([BRIR_data.DesiredT30(hf_bands), ...
    %     BRIR_data.OriginalT30(hf_bands)], [], 2);
    % limit modification to follow slope of original
    hf_index = find(BRIR_data.RTFreqVector > BRIR_data.RTModRegFreq, 1, 'first');
    if hf_index < length(BRIR_data.RTFreqVector)
        hf_index = hf_index + find(diff(BRIR_data.DesiredT30(hf_index:end)) > 0, 1, 'first');
    end
    hf_index = hf_index - 1;
    BRIR_data.DesiredT30(hf_index:end) = cumsum(...
        [BRIR_data.DesiredT30(hf_index); diff(BRIR_data.OriginalT30(hf_index:end))]);
end

d0 = log(1e6) ./ (2 * BRIR_data.OriginalT30);
d1 = log(1e6) ./ (2 * BRIR_data.DesiredT30);
d0(isnan(d1)) = 0;
d0(isnan(d0)) = 0;
d1(isnan(d0)) = 0;
d1(isnan(d1)) = 0;

H_freq = fft(BRIR, 2*BRIR_data.FilterBank_snfft);
G = fft(BRIR_data.FilterBank_g, 2*BRIR_data.FilterBank_snfft);

BRIR_mod = zeros(size(BRIR));
for band = 1 : length(BRIR_data.FilterBank_f1)
    % Filter the result with octave band filter
    y = real(ifft(G(:, band) .* H_freq));
    
    y = y(BRIR_data.FilterBank_snfft+1:end, :);
    H_filt = y(1:BRIR_data.FilterBank_snfft, :);
    
    H_corrected = H_filt .* exp(-(0:BRIR_data.FilterBank_snfft-1)' ...
        / BRIR_data.fs .* (d1(band)-d0(band))); % changing reverb slope
    
    BRIR_mod = BRIR_mod + H_corrected;
end

if ~isempty(Plot_data) && Plot_data.PlotAnalysisFlag
    disp('Started modifying late reverberation');

    BRIR_plot = BRIR;
    BRIR_plot(1:floor(BRIR_data.MixingTime * Plot_data.fs), :) = 0;
    BRIR_mod_plot = BRIR_mod;
    BRIR_mod_plot(1:floor(BRIR_data.MixingTime * Plot_data.fs), :) = 0;
    t = (0 : length(BRIR_plot)-1).' / Plot_data.fs * 1000;
    f = (0 : length(BRIR_plot)-1).' * Plot_data.fs / length(BRIR_plot);
    BRIR_max = ceil(max(mag2db(abs(BRIR_plot)), [], 'all') / 5) * 5;
    BRTF_max = ceil(max(mag2db(abs(fft(BRIR_plot))), [], 'all') / 5) * 5;
    
    % remember and set interpreter for visualization purposes
    default_intpreter = get(0, 'DefaultTextInterpreter');
    set(0, 'DefaultTextInterpreter', 'Latex');

    fig_name = sprintf('%s_BRIR_LR_RTMod', Plot_data.name);
    fig_name = strrep(fig_name, '\', '');
    fig = figure('NumberTitle', 'off', 'Name', fig_name);
    fig.Position(3:4) = fig.Position(3:4) * 2;
    
    tl = tiledlayout(3, 2, 'TileSpacing', 'tight', 'Padding', 'tight');
    title(tl, Plot_data.name, 'Interpreter', 'none');
    
    ax(1) = nexttile(tl);
    plot(t, mag2db(abs(BRIR_plot)), 'Color', 'k');
    xlim([BRIR_data.MixingTime * 1000, t(end)]);
    ylim([BRIR_max - 70, BRIR_max]);
    xlabel('Time [ms]');
    ylabel('Energy Time Curve [dB]');
    grid on;
    
    ax(2) = nexttile(tl);
    plot(t, mag2db(abs(BRIR_mod_plot)), 'Color', Plot_data.colors(4, :));
    xlim([BRIR_data.MixingTime * 1000, t(end)]);
    ylim([BRIR_max - 70, BRIR_max]);
    xlabel('Time [ms]');
    ylabel('Energy Time Curve [dB]');
    grid on;
    set(ax(2), 'YAxisLocation', 'right');
    linkaxes(ax, 'xy');
    
    nexttile(tl, [1, 2]);
    lgd_str = {'before', 'after'};
    semilogx(BRIR_data.RTFreqVector, BRIR_data.OriginalT30, 'LineWidth', 2, 'Color', 'k');
    hold on;
    if BRIR_data.RTModRegFreq
        semilogx(BRIR_data.RTFreqVector, BRIR_data.DesiredT30_unlimited, ...
            'LineStyle', ':', 'LineWidth', 2, 'Color', Plot_data.colors(4, :));
        lgd_str = {lgd_str{1}, 'after (unregularized)', lgd_str{2}};
    end
    semilogx(BRIR_data.RTFreqVector, BRIR_data.DesiredT30, 'LineWidth', 2, 'Color', Plot_data.colors(4, :));
    xlim([BRIR_data.RTFreqVector(1) / 1.1, BRIR_data.RTFreqVector(end) * 1.1]);
    yl = ylim;
    ylim([floor(yl(1) * 10) / 10, ceil(yl(2) * 10) / 10]);
%     xticks(BRIR_data.RTFreqVector(1:BRIR_data.BandsPerOctave:length(BRIR_data.RTFreqVector)));
%     xticklabels(string(round(BRIR_data.RTFreqVector(1:BRIR_data.BandsPerOctave:end))));
    xticks(BRIR_data.RTFreqVector(1:length(BRIR_data.RTFreqVector)));
    xticklabels(string(ceil(BRIR_data.RTFreqVector)));
    xlabel('Frequency band [Hz]');
    ylabel('Reverberation time [s]');
    lgd = legend(lgd_str, 'Location', 'North', 'Orientation', 'horizontal');
    title(lgd, 'Late reverberation RTmod');
    grid on;
    
    ax(1) = nexttile(tl);
    semilogx(f, mag2db(abs(fft(BRIR_plot))), 'Color', 'k');
    xlim([30, 20e3]);
    ylim([BRTF_max - 60, BRTF_max]);
    xlabel('Frequency [Hz]');
    ylabel('Magnitude [dB]');
    grid on;
    
    ax(2) = nexttile(tl);
    semilogx(f, mag2db(abs(fft(BRIR_mod_plot))), 'Color', Plot_data.colors(4, :));
    xlim([30, 20e3]);
    ylim([BRTF_max - 60, BRTF_max]);
    xlabel('Frequency [Hz]');
    ylabel('Magnitude [dB]');
    grid on;
    set(ax(2), 'YAxisLocation', 'right');
    linkaxes(ax, 'xy');
    
    drawnow;

    % reset interpreter
    set(0, 'DefaultTextInterpreter', default_intpreter); 

    if Plot_data.PlotExportFlag
        % create target directory if it doesn't exist
        [~, ~] = mkdir(Plot_data.DestinationPath);

        file_name = fullfile(Plot_data.DestinationPath, [fig_name, '.', PLOT_FMT]);
        fprintf('Exporting plot "%s".\n', file_name);
        exportgraphics(fig, file_name);
    end
    
    fprintf('\n');
end

end