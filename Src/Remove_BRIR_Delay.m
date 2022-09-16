% Copyright (c) Facebook, Inc. and its affiliates.

function [BRIR_TimeData, BRIR_full] = Remove_BRIR_Delay(...
    BRIR_TimeData, BRIR_full, thres_db)

disp('Started removing initial BRIR delay');

thres = db2mag(thres_db);
cutOffIndex = Inf;
for iBRIR = 1 : size(BRIR_TimeData, 3)
    for iChannel = 1 : size(BRIR_TimeData, 2)
        cutOffIndexNew = find(abs(BRIR_TimeData(:, iChannel, iBRIR)) ...
            > thres * max(abs(BRIR_TimeData(:, iChannel, iBRIR))), 1, 'first');
        cutOffIndex = min(cutOffIndex, cutOffIndexNew);
    end
end

fprintf('Removing %d initial samples.\n\n', cutOffIndex);
BRIR_TimeData = BRIR_TimeData(cutOffIndex:end, :, :);
BRIR_full = BRIR_full(cutOffIndex:end, :, :);

end
