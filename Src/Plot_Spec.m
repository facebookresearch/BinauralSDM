% Copyright (c) Facebook, Inc. and its affiliates.

function Plot_Spec(SRIR_data, Plot_data, fig_name)

PLOT_FMT = 'pdf';

fig_name = strrep(fig_name, '\', '');

timeFrequencyVisualization({SRIR_data.P_RIR}, Plot_data);
fig = gcf;
set(fig, 'NumberTitle', 'off', 'Name', fig_name);

drawnow;

if Plot_data.PlotExportFlag
    % create target directory if it doesn't exist
    [~, ~] = mkdir(Plot_data.DestinationPath);

    file_name = fullfile(Plot_data.DestinationPath, [fig_name, '.', PLOT_FMT]);
    fprintf('Exporting plot "%s".\n', file_name);
    exportgraphics(fig, file_name);
end

fprintf('\n');

end
