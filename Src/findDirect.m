% Copyright (c) Facebook, Inc. and its affiliates.

function dirIdx = findDirect(x, minPeakDistance, plotOpt)

% x is assumed to be a single-channel RIR
% dirIdx is the index of the direct-sound arrival

if nargin == 1
    minPeakDistance = 100;
    plotOpt = false;
elseif nargin == 2
    plotOpt = false;
end
   
logMagX   = 20*log10(abs(x));
[~, locs] = findpeaks(logMagX, 'MinPeakDistance', minPeakDistance);
dirIdx    = find(logMagX(locs) >= (max(logMagX) - 11), 1, 'first');
dirIdx    = locs(dirIdx);

if plotOpt
    figure
    s1 = subplot(2, 1, 1);
    plot(logMagX);
    hold on
    plot(dirIdx, logMagX(dirIdx), 'ro', 'markerfacecolor', 'r');
    grid on
    s2 = subplot(2, 1, 2);
    plot(x);
    hold on
    plot(dirIdx, x(dirIdx), 'ro', 'markerfacecolor', 'r');
    grid on    
    linkaxes([s1 s2], 'x');
end