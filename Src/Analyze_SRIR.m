% Copyright (c) Facebook, Inc. and its affiliates.

function SRIR_data = Analyze_SRIR(SRIR_data, SDM_struct)
% This function takes in a SRIR_data struct and a SDM_struct and computes
% the DOA estimation using SDM.
%
% Dependencies: 
%       - SDM Toolbox https://www.mathworks.com/matlabcentral/fileexchange/56663-sdm-toolbox
%
% Author: Sebastià V. Amengual
% Last Modified: 07/09/20


% Computing DOA
SRIR_data.DOA = SDMPar(SRIR_data.Raw_RIR, SDM_struct);

if SRIR_data.DiffComponent == 1
    error('This will be implemented in a future release!')  
%     disp('Estimating Diffuse Component'); tic;
%     SRIR_data.DiffFunc = estimateDiffuseness(SRIR_data);
%     SRIR_data.DiffFunc = SRIR_data.DiffFunc(SRIR_data.DSonset:end,:);
% 
%     SRIR_data.SpecRIR = SRIR_data.P_RIR .* (1-SRIR_data.DiffFunc);
%     SRIR_data.DiffRIRmono = SRIR_data.P_RIR .* SRIR_data.DiffFunc;  
%     
%     timer = toc;
%     disp(['Done! Time elapsed: ' num2str(timer) 'seconds']);
end

    
% The Raw RIR and DOA data need to be cropped now, after the DOA and
% diffuseness estimation. If the first sample in the raw RIR is already 
% the direct  sound, the DOA estimation is wrong - it does not find a 
% solution and returns 0º,0º.
SRIR_data.Raw_RIR = SRIR_data.Raw_RIR(SRIR_data.DSonset:end,:);
SRIR_data.DOA = SRIR_data.DOA(SRIR_data.DSonset:end,:);

disp('Smoothing DOA data'); tic;
SRIR_data = Smooth_DOA(SRIR_data);
timer = toc;
disp(['Done! Time elapsed: ' num2str(timer) 'seconds']);

if SRIR_data.AlignDOA == 1
    SRIR_data = align_DOA(SRIR_data);
end




