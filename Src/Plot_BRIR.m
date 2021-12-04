% Copyright (c) Facebook, Inc. and its affiliates.

function Plot_BRIR(BRIR_data, BRIR_DS, BRIR_ER, BRIR_LR, Plot_data)

PLOT_FMT = 'pdf';

% get index of 0,0 BRIR
BRIR_idx = find(sum(BRIR_data.Directions == [0, 0], 2) == 2, 1);
if isempty(BRIR_idx)
    % get middle index (direction may be arbitrary)
    BRIR_idx = floor(size(BRIR_data.Directions, 1) / 2);
end

% determine IR lengths
for ear = 1 : size(BRIR_DS, 2)
    len_DS(ear, :) = [find(BRIR_DS(:, ear, BRIR_idx), 1, 'first') - 1; ...
        find(BRIR_DS(:, ear, BRIR_idx), 1, 'last')];
    len_ER(ear, :) = [find(BRIR_ER(:, ear, BRIR_idx), 1, 'first') - 1; ...
        find(BRIR_ER(:, ear, BRIR_idx), 1, 'last')];
    len_LR(ear, :) = [find(BRIR_LR(:, ear), 1, 'first') - 1; ...
        find(BRIR_LR(:, ear), 1, 'last')];
end

% zero pad IRs
BRIR_DS(end:length(BRIR_LR), :) = 0;
BRIR_ER(end:length(BRIR_LR), :) = 0;
BRIR_full = BRIR_DS + BRIR_ER + BRIR_LR;
BRIR_max = ceil(max(mag2db(abs(BRIR_full)), [], 'all') / 5) * 5;

% calculate time and frequency vectors
t = (0 : length(BRIR_LR)-1).' / Plot_data.fs * 1000;
f = (0 : length(BRIR_LR)-1).' * Plot_data.fs / length(BRIR_LR);

% calculate magnitude spectrum
BRTF_full = mag2db(abs(fft(BRIR_full)));
BRTF_max = ceil(max(BRTF_full(:, :, BRIR_idx), [], 'all') / 5) * 5;

% remember and set interpreter for visualization purposes
default_intpreter = get(0, 'DefaultTextInterpreter');
set(0, 'DefaultTextInterpreter', 'Latex');

ear_str = {'left', 'right'};
dir_str = sprintf('BRIR_az%del%d', BRIR_data.Directions(BRIR_idx, :));
fig_name = sprintf('%s_%s', Plot_data.name, dir_str);
fig_name = strrep(fig_name, '\', '');
fig = figure('NumberTitle', 'off', 'Name', fig_name);
fig.Position(3) = fig.Position(3) * size(BRIR_DS, 2);
fig.Position(4) = fig.Position(4) * 2;

tl = tiledlayout(size(BRIR_DS, 2), 2, 'TileSpacing', 'tight', 'Padding', 'tight');
title(tl, Plot_data.name, 'Interpreter', 'none');
for ear = 1 : size(BRIR_DS, 2)
    ax(ear) = nexttile(tl);
    plot(t, mag2db(abs(BRIR_DS(:, ear, BRIR_idx))), 'Color', Plot_data.colors(2, :));
    hold on;
    plot(t, mag2db(abs(BRIR_ER(:, ear, BRIR_idx))), 'Color', Plot_data.colors(3, :));
    plot(t, mag2db(abs(BRIR_LR(:, ear))), 'Color', Plot_data.colors(4, :));
    xlim([0, t(end)]);
    ylim([BRIR_max - 80, BRIR_max]);
    xlabel('Time [ms]');
    ylabel('Energy Time Curve [dB]');
    grid on;
    
    text(.02, .98, sprintf('%d ... %d samples', len_DS(ear, :)), ...
        'Units', 'normalized', 'Color', Plot_data.colors(2, :), ...
        'FontWeight', 'bold', 'Interpreter', 'none',  ...
        'HorizontalAlignment', 'left', 'VerticalAlignment', 'top');
    text(.5, .98, sprintf('%d ... %d samples', len_ER(ear, :)), ...
        'Units', 'normalized', 'Color', Plot_data.colors(3, :), ...
        'FontWeight', 'bold', 'Interpreter', 'none',  ...
        'HorizontalAlignment', 'center', 'VerticalAlignment', 'top');
    text(.98, .98, sprintf('%d ... %d samples', len_LR(ear, :)), ...
        'Units', 'normalized', 'Color', Plot_data.colors(4, :), ...
        'FontWeight', 'bold', 'Interpreter', 'none',  ...
        'HorizontalAlignment', 'right', 'VerticalAlignment', 'top');
end
set(ax(end), 'YAxisLocation', 'right');
linkaxes(ax, 'xy');

for ear = 1 : size(BRIR_DS, 2)
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
    title(lgd, sprintf('%s  (%s)', dir_str, ear_str{ear}), 'Interpreter', 'None');
end
set(ax(end), 'YAxisLocation', 'right');
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
