% Copyright (c) Facebook, Inc. and its affiliates.

function Plot_BRIR(BRIR_data, BRIR_DS, BRIR_ER, BRIR_LR, Plot_data)

PLOT_FMT = 'pdf';

% get index of 0,0 BRIR
BRIR_idx = find(sum(BRIR_data.Directions == [0, 0], 2) == 2, 1);
if isempty(BRIR_idx)
    % get middle index (direction may be arbitrary)
    BRIR_idx = floor(size(BRIR_data.Directions, 1) / 2);
end

% zero pad IRs
BRIR_DS(end:length(BRIR_LR), :) = 0;
BRIR_ER(end:length(BRIR_LR), :) = 0;
BRIR_full = BRIR_DS + BRIR_ER + BRIR_LR;
BRTF_full = mag2db(abs(fft(BRIR_full)));
BRTF_max = ceil(max(BRTF_full(:, :, BRIR_idx), [], 'all') / 5) * 5;

% calculate time and frequency vectors
t = (0 : length(BRIR_LR)-1).' / Plot_data.fs * 1000;
f = (0 : length(BRIR_LR)-1).' * Plot_data.fs / length(BRIR_LR);

% remember and set interpreter for visualization purposes
default_intpreter = get(0, 'DefaultTextInterpreter');
set(0, 'DefaultTextInterpreter', 'Latex');

dir_str = sprintf('BRIR_az%del%d', BRIR_data.Directions(BRIR_idx, :));
fig_name = sprintf('%s_%s', Plot_data.name, dir_str);
fig_name = strrep(fig_name, '\', '');
fig = figure('NumberTitle', 'off', 'Name', fig_name);
fig.Position(3:4) = fig.Position(3:4) * 2;

tl = tiledlayout(2, 2, 'TileSpacing', 'tight', 'Padding', 'tight');
title(tl, Plot_data.name);
for ear = 1 : 2
    ax(ear) = nexttile(tl); %#ok<AGROW>
    plot(t, BRIR_DS(:, ear, BRIR_idx), 'Color', Plot_data.colors(2, :));
    hold on;
    plot(t, BRIR_ER(:, ear, BRIR_idx), 'Color', Plot_data.colors(3, :));
    plot(t, BRIR_LR(:, ear), 'Color', Plot_data.colors(4, :));
    xlabel('Time [ms]');
    ylabel('Amplitude');
    grid on; axis tight;
    if ear == 2
        set(ax(ear), 'YAxisLocation', 'right');
        linkaxes(ax, 'xy');
    end
end
for ear = 1 : 2
    ax(ear) = nexttile(tl);
    semilogx(f, BRTF_full(:, ear, BRIR_idx), ...
        'Color', Plot_data.colors(1, :), 'LineWidth', Plot_data.linewidth(1) / 2);
    hold on;
    semilogx(f, mag2db(abs(fft(BRIR_LR(:, ear)))), ...
        'Color', Plot_data.colors(4, :), 'LineWidth', Plot_data.linewidth(4) / 2);
    semilogx(f, mag2db(abs(fft(BRIR_ER(:, ear, BRIR_idx)))), ...
        'Color', Plot_data.colors(3, :), 'LineWidth', Plot_data.linewidth(3) / 2);
    semilogx(f, mag2db(abs(fft(BRIR_DS(:, ear, BRIR_idx)))), ...
        'Color', Plot_data.colors(2, :), 'LineWidth', Plot_data.linewidth(2) / 2);
    xlabel('Frequency [Hz]');
    ylabel('Magnitude [dB]');
    xlim([30, 20e3]);
    ylim([BRTF_max - 60, BRTF_max]);
    grid on;
    lgd = legend(ax(ear), ...
        {'Combined', 'Late reverb', 'Early reflections', 'Direct sound'}, ...
            'Location', 'SouthWest');
    title(lgd, ['Left ', dir_str]);
    if ear == 2
        title(lgd, [dir_str, '  (right)'], 'Interpreter', 'None');
        set(ax(ear), 'YAxisLocation', 'right');
        linkaxes(ax, 'xy');
    else
        title(lgd, [dir_str, '  (left)'], 'Interpreter', 'None');
    end
end

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
