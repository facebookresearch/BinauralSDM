% Copyright (c) Facebook, Inc. and its affiliates.

function Plot_Spec(SRIR_data, Plot_data, fig_name)

PLOT_FMT = 'pdf';

% remember and set interpreter for visualization purposes
default_intpreter = get(0, 'DefaultTextInterpreter');
set(0, 'DefaultTextInterpreter', 'Latex');
default_name = Plot_data.name;
Plot_data.name = strrep(Plot_data.name, '_', '\_');

timeFrequencyVisualization({SRIR_data.P_RIR}, Plot_data);
fig = gcf;
set(fig, 'NumberTitle', 'off', 'Name', fig_name);

drawnow;

% reset interpreter
set(0, 'DefaultTextInterpreter', default_intpreter); 
Plot_data.name = default_name;

if Plot_data.PlotExportFlag
    % create target directory if it doesn't exist
    [~, ~] = mkdir(Plot_data.DestinationPath);

    file_name = fullfile(Plot_data.DestinationPath, [fig_name, '.', PLOT_FMT]);
    fprintf('Exporting plot "%s".\n', file_name);
    exportgraphics(fig, file_name);
end

fprintf('\n');

end
