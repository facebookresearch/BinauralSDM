% Copyright (c) Facebook, Inc. and its affiliates.

function SRIR_data = removeER(SRIR_data, threshold, refl_window, plotflag)
% removeER(SRIR_data, threshold, refl_window)
% This functions removes the energy of a room impulse response that is
% below a certain threshold and replaces the samples by zeros. 
%
% Input arguments:
%   - SRIR_data: SRIR_data struct as created by the function
%   create_SRIR_data().
%   - threshold: Level in dB below the maximum. The energy below this level
%   will be removed. The value has to be positive.
%   - refl_window: Length in samples for a Tukey window to be applied
%   around the samples that are kept. It can be regarded as the duration of
%   a reflection in time.
%   - plotflag: flag (0/1) to determine if the window and resulting RIR are
%   plotted.
%
% Author: Sebastià V. Amengual
% Last modified: 07/08/2019

w = tukeywin(refl_window,0.9);

idx = find(db(abs(SRIR_data.P_RIR))>max(db(abs(SRIR_data.P_RIR)))-threshold);
winRIR = zeros(length(SRIR_data.P_RIR),1);

winRIR(1:refl_window) = [ones(refl_window/2,1) ; w(refl_window/2+1:end)];

for i=1:length(idx)
    if idx(i)<refl_window/2
    else
        for iw = 1:length(w)
            if winRIR(idx(i)-refl_window/2+iw)<w(iw)
                winRIR(idx(i)-refl_window/2+iw) = w(iw);
            end
        end
    end
end

SRIR_data.P_RIR = winRIR.*SRIR_data.P_RIR;

if plotflag
    figure;
    plot(winRIR)
    hold on
    plot(SRIR_data.P_RIR);
end