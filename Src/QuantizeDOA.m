% Copyright (c) Facebook, Inc. and its affiliates.

function [SRIR_data, idx] = QuantizeDOA(SRIR_data, gridSize, DSGuard, ~)
% This function quantizes the DOA data of a SDM RIR using a Lebedev Grid of
% with the specified number of points. Beware that the Lebedev Grid will be
% aligned towards 0az, 0el. 
% Input Arguments:
%   - SRIR_data: Struct with the SRIR information, generated with
%   create_SRIR.m
%   - gridSize: Size of the Lebedev Sphere grid.
%   - DSGuard: Number of samples unaffected by the quantization at the
%   beginning of the RIR.
%   - optim: Flag for optimal quantization, depending on the energy of the
%   reflections (To do, not implemented)
%
% Author: Sebastia V. Amengual
% Last modified: 4/22/19

% Finding DOA of the direct sound.
DS_DOA = SRIR_data.DOA(SRIR_data.DS_idx-SRIR_data.DSonset+1,:);

if gridSize == 1
    % Assigning all DOA to the same direction as direct sound
    SRIR_data.DOA(1:SRIR_data.MixingTime*SRIR_data.fs,:) = ones(SRIR_data.MixingTime*SRIR_data.fs,3).*DS_DOA;
    idx = [];
else
    if gridSize == 2
        LS.x = [0 ; 0];
        LS.y = [1 ; -1];
        LS.z = [0 ; 0];
    else
        % Creating Lebedev grid of specified size
        LS = getLebedevSphere(gridSize);
    end
    
    % Assigning direct sound DOA to the initial samples, up to DSGuard
    SRIR_data.DOA(1:DSGuard+(SRIR_data.DS_idx-SRIR_data.DSonset),:) = ones(DSGuard+(SRIR_data.DS_idx-SRIR_data.DSonset),1).*DS_DOA;
    
    % Finding the nearest neighbour for the quantization
    idx = knnsearch([LS.x LS.y LS.z], SRIR_data.DOA);
    
    % Assigning quantized DOA
    SRIR_data.DOA(DSGuard+(SRIR_data.DS_idx-SRIR_data.DSonset)+1:end,:) = ...
        [LS.x(idx(DSGuard+(SRIR_data.DS_idx-SRIR_data.DSonset)+1:end)) ...
         LS.y(idx(DSGuard+(SRIR_data.DS_idx-SRIR_data.DSonset)+1:end)) ...
         LS.z(idx(DSGuard+(SRIR_data.DS_idx-SRIR_data.DSonset)+1:end))];
end



