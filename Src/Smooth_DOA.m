% Copyright (c) Facebook, Inc. and its affiliates.

function SRIR_data = Smooth_DOA(SRIR_data)
% This function smoothes the DOA data retrieved from SDM. At the moment it
% is only a moving average. 
%
% Author: Sebastià V. Amengual
% Last modified: 07/15/2020
%
% To-Do: Include DBSCAN clustering

if SRIR_data.DOASmooth < 2; return; end

fprintf('Smoothing DOA using a window of %d samples.\n', SRIR_data.DOASmooth);
SRIR_data.DOA(:,1) = movmean(SRIR_data.DOA(:,1),SRIR_data.DOASmooth);
SRIR_data.DOA(:,2) = movmean(SRIR_data.DOA(:,2),SRIR_data.DOASmooth);
SRIR_data.DOA(:,3) = movmean(SRIR_data.DOA(:,3),SRIR_data.DOASmooth);

end
