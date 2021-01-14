% Copyright (c) Facebook, Inc. and its affiliates.

function [BRIR_TimeData, BRIR_Full] = removeInitialDelay(BRIR_TimeData,BRIR_Full,thresdB,BRIR_Length)

%thresdB = -60;

thres = 10^(thresdB/20);
cutOffIndex = Inf;
nBRIR = size(BRIR_TimeData,3);
for iBRIR = 1:nBRIR
    for iChannel = 1:2
        cutOffIndexNew = find(abs(BRIR_TimeData(:,iChannel,iBRIR))>thres*max(abs(BRIR_TimeData(:,iChannel,iBRIR))),1,'first');
        cutOffIndex = min(cutOffIndex,cutOffIndexNew);
    end
end

BRIR_TimeData = BRIR_TimeData(cutOffIndex:cutOffIndex+BRIR_Length-1,:,:);
BRIR_Full = BRIR_Full(cutOffIndex:end,:,:);
