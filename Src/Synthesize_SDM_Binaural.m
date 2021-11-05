% Copyright (c) Facebook, Inc. and its affiliates.

function BRIR = Synthesize_SDM_Binaural(...
    SRIR_data, BRIR_data, HRTF_TransL, HRTF_TransR, rot, full)
% This function re-synthesizes a binaural room impulse response (BRIR)
% using the Spatial Decomposition Method (SDM) and an arbitrary HRTF
% dataset. 
%
% Input arguments:
%       - SRIR_data: Structure created using the function 
%         create_SRIR_data.m, containing at least a pressure RIR and a DOA
%         vector.
%       - BRIR_data: Structure created using create_BRIR_data.m, containing
%         information regarding the rendering parameters of the 
%         resynthesized BRIR.
%       - HRTF_TransL: Left HRIR, row vector [N 1].
%       - HRTF_TransR: Right HRIR, row vector [N 1].
%       - rot: Rotation of the synthesized BRIR, in the format [az el]
%         (in degrees).
%       - full: Flag that marks if the entire BRIR should be rendered
%         (true) or only until the mixing time (false).
%
% Output arguments:
%       - BRIR: Re-synthesized binaural room impulse response
%
% Author: Sebastia V. Amengual (samengual@fb.com)
% Last modified: 04/15/2019

% Synthesize the spatial impulse response with NLS as binaural
DOA_rad = zeros(size(SRIR_data.DOA));

az_deg = rot(1);
el_deg = rot(2);

DOA_cart = (rotz(az_deg)*roty(-el_deg)*SRIR_data.DOA')';
[DOA_rad(:,1), DOA_rad(:,2), DOA_rad(:,3)] = cart2sph(DOA_cart(:,1),DOA_cart(:,2),DOA_cart(:,3));
[DOA_cart(:,1), DOA_cart(:,2), DOA_cart(:,3)] = sph2cart(DOA_rad(:,1),DOA_rad(:,2),1);

L_HRTF = length(HRTF_TransL(:,1));

Left_RIR = zeros(length(SRIR_data.P_RIR)+L_HRTF-1,1);
Right_RIR = zeros(length(SRIR_data.P_RIR)+L_HRTF-1,1);

if full == 1
    N = BRIR_data.Length*BRIR_data.fs;
else
    N = (BRIR_data.MixingTime+BRIR_data.TimeGuard)*BRIR_data.fs;
end

[idx, ~] = knnsearch(BRIR_data.HRTF_cartDir, DOA_cart(1:N,:));

if SRIR_data.DiffComponent
    P_IR = SRIR_data.SpecRIR;
    
    % Spatializing diffuse streams
    DiffDOA = getLebedevSphere(SRIR_data.DiffN);   
    [idxDiff, ~] = knnsearch(BRIR_data.HRTF_cartDir, [DiffDOA.x, DiffDOA.y, DiffDOA.z]);
    for diff_i=1:size(SRIR_data.DiffRIR,2)
        Left_RIR = Left_RIR + conv(SRIR_data.DiffRIR(:,diff_i), HRTF_TransL(:,idxDiff(diff_i)));
        Right_RIR = Right_RIR + conv(SRIR_data.DiffRIR(:,diff_i), HRTF_TransR(:,idxDiff(diff_i)));
    end
else
    P_IR = SRIR_data.P_RIR;
end

Left_RIR = Left_RIR(1:N);
Right_RIR = Right_RIR(1:N);

SRIR_data.Diff_BRIR = [Left_RIR Right_RIR];

Left_RIR = zeros(length(SRIR_data.P_RIR)+L_HRTF-1,1);
Right_RIR = zeros(length(SRIR_data.P_RIR)+L_HRTF-1,1);

for samp_n=1:length(SRIR_data.P_RIR(1:N))
    Left_RIR(samp_n:samp_n+L_HRTF-1) = Left_RIR(samp_n:samp_n+L_HRTF-1) ...
        + P_IR(samp_n).*HRTF_TransL(:,idx(samp_n));
    Right_RIR(samp_n:samp_n+L_HRTF-1) = Right_RIR(samp_n:samp_n+L_HRTF-1) ...
        + P_IR(samp_n).*HRTF_TransR(:,idx(samp_n));  
end

Left_RIR = Left_RIR(1:N);
Right_RIR = Right_RIR(1:N);

SRIR_data.Spec_BRIR = [Left_RIR, Right_RIR];

BRIR = SRIR_data.Diff_BRIR + SRIR_data.Spec_BRIR;

end
