% Copyright (c) Facebook, Inc. and its affiliates.

function SRIR_data = Align_DOA(SRIR_data)
%% This function takes in a BRIR_data struct and aligns the DOA estimates to
% be located at az=0, el=0 for the direct sound.
% 
% The input argument is a struct of type BRIR_data. This struct must 
% contain a field P_RIR with a pressure impulse response and a field DOA 
% with the estimated DOA values in cartesian coordinates (right hand system
% where X=front, Y=right, Z=up)

% Author: Sebastia V. Amengual
% Last modified: 11/09/2021

% Locate direct sound - assumed to be the avaerage of the first samples
[DOA_raw_az_rad, DOA_raw_el_rad, ~] = cart2sph(...
    SRIR_data.DOA(:, 1), SRIR_data.DOA(:, 2), SRIR_data.DOA(:, 3));
DOA_raw_az_deg = rad2deg(DOA_raw_az_rad);
DOA_raw_el_deg = rad2deg(DOA_raw_el_rad);
DOA_DS_avg_az_deg = mean(DOA_raw_az_deg(1:SRIR_data.DOAOnsetLength));
DOA_DS_avg_el_deg = mean(DOA_raw_el_deg(1:SRIR_data.DOAOnsetLength));

% Locate direct sound - assumed to be the sample with highest pressure
[~, DS_peak] = max(abs(SRIR_data.P_RIR));
DOA_DS_peak = SRIR_data.DOA(DS_peak, :);
[DOA_DS_peak_az_rad, DOA_DS_peak_el_rad, ~] = cart2sph(...
    DOA_DS_peak(1), DOA_DS_peak(2), DOA_DS_peak(3));
DOA_DS_peak_az_deg = rad2deg(DOA_DS_peak_az_rad);
DOA_DS_peak_el_deg = rad2deg(DOA_DS_peak_el_rad);

% % plot comparison
% figure('NumberTitle', 'off', 'Name', 'Align_DOA');
% colors = colororder;
% plot([DOA_raw_az_deg, DOA_raw_el_deg], 'LineWidth', 2);
% hold on;
% line([0, SRIR_data.DOAOnsetLength], [DOA_DS_avg_az_deg, DOA_DS_avg_az_deg], ...
%     'LineStyle', ':', 'LineWidth', 5, 'Color', colors(1, :));
% line([0, SRIR_data.DOAOnsetLength], [DOA_DS_avg_el_deg, DOA_DS_avg_el_deg], ...
%     'LineStyle', ':', 'LineWidth', 5, 'Color', colors(2, :));
% stem(DS_peak, DOA_DS_peak_az_deg, 'filled', 'MarkerSize', 10, ...
%     'LineStyle', 'none', 'Color', colors(1, :));
% stem(DS_peak, DOA_DS_peak_el_deg, 'filled', 'MarkerSize', 10, ...
%     'LineStyle', 'none', 'Color', colors(2, :));
% xlim([0, max([SRIR_data.DOAOnsetLength * 2.5, DS_peak + 50])]);
% ylim([-181, 181]);
% xlabel('Samples');
% ylabel('DOA angle [deg]');
% yyaxis right;
% plot(SRIR_data.Raw_RIR(:, 7));
% ylabel('Amplitude');
% legend({'Raw az', 'Raw el', 'DS avg az', 'DS avg el', 'DS peak az', 'DS peak el', 'Raw RIR'}, ...
%     'Interpreter', 'none', 'Location', 'Best');
% grid on;

% Pick method depending on timing of peak sample
if DS_peak > SRIR_data.DOAOnsetLength
    az_deg = DOA_DS_avg_az_deg;
    el_deg = DOA_DS_avg_el_deg;
else
    az_deg = DOA_DS_peak_az_deg;
    el_deg = DOA_DS_peak_el_deg;
end

fprintf('Aligning DOA by %.1f deg azimuth and %.1f deg elevation.\n', ...
    az_deg, el_deg);
SRIR_data = Rotate_DOA(SRIR_data, az_deg, el_deg);

end
