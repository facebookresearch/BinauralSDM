% Copyright (c) Facebook, Inc. and its affiliates.

function BRIR = Synthesize_SDM_Binaural(...
    SRIR_data, BRIR_data, HRIR, rot, full)
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
%       - HRIR: Head related imupulse responses, vector [samples 2 directions].
%       - rot: Rotation of the synthesized BRIR, in the format [az el]
%         (in degrees).
%       - full: Flag that marks if the entire BRIR should be rendered
%         (true) or only until the mixing time (false).
%
% Output arguments:
%       - BRIR: Re-synthesized binaural room impulse response
%
% Author: Sebastia V. Amengual (samengual@fb.com)
% Last modified: 11/19/2021

% Synthesize the spatial impulse response with NLS as binaural
if full
    N = BRIR_data.Length;
else
    N = BRIR_data.MixingTime + BRIR_data.TimeGuard;
end
N = ceil(N * BRIR_data.fs);

HRIR_len = size(HRIR, 1);
SRIR_data.Diff_BRIR = zeros(length(SRIR_data.P_RIR)+HRIR_len-1, 2);
if SRIR_data.DiffComponent
    P_IR = SRIR_data.SpecRIR;
    
    % Spatializing diffuse streams
    DiffDOA = getLebedevSphere(SRIR_data.DiffN);   
    [idxDiff, ~] = knnsearch(BRIR_data.HRTF_cartDir, [DiffDOA.x, DiffDOA.y, DiffDOA.z]);
    for diff_i = 1 : size(SRIR_data.DiffRIR, 2)
        for ear = 1 : size(HRIR, 2)
            SRIR_data.Diff_BRIR(:, ear) = SRIR_data.Diff_BRIR(:, ear) ...
                + conv(SRIR_data.DiffRIR(:, diff_i), HRIR(:, ear, idxDiff(diff_i)));
        end
    end
else
    P_IR = SRIR_data.P_RIR;
end
SRIR_data.Diff_BRIR =  SRIR_data.Diff_BRIR(1:N, :);

az_deg = rot(1);
el_deg = rot(2);
DOA_cart = (rotz(az_deg) * roty(-el_deg) * SRIR_data.DOA')';
[idx, ~] = knnsearch(BRIR_data.HRTF_cartDir, DOA_cart(1:N, :));

SRIR_data.Spec_BRIR = zeros(length(SRIR_data.P_RIR)+HRIR_len-1, 2);
for samp_n = 1 : N
    for ear = 1 : size(HRIR, 2)
        SRIR_data.Spec_BRIR(samp_n:samp_n+HRIR_len-1, ear) = ...
            SRIR_data.Spec_BRIR(samp_n:samp_n+HRIR_len-1, ear) ...
            + P_IR(samp_n) .* HRIR(:, ear, idx(samp_n));
    end
end
SRIR_data.Spec_BRIR =  SRIR_data.Spec_BRIR(1:N, :);

BRIR = SRIR_data.Diff_BRIR + SRIR_data.Spec_BRIR;

end
