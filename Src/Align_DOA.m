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
% Last modified: 11/08/2021

% Locate direct sound - assumed to be the sample with highest pressure
DOA_DS = SRIR_data.DOA(abs(SRIR_data.P_RIR)==max(abs(SRIR_data.P_RIR)),:);

% Retrieve the angular offset
[az_rad,el_rad,~] = cart2sph(DOA_DS(1),DOA_DS(2),DOA_DS(3));

% Offset to degrees
az_deg = rad2deg(az_rad);
el_deg = rad2deg(el_rad);

fprintf('Aligning DOA by %.1f deg azimuth and %.1f deg elevation.\n', ...
    az_deg, el_deg);
SRIR_data = Rotate_DOA(SRIR_data, az_deg, el_deg);

end
