% Copyright (c) Facebook, Inc. and its affiliates.

function SRIR_data = shift_P_RIR(SRIR_data)
% This function circular shifts the pressure impulse response, given that
% some microphones e.g. Eigenmike introduce a time latency when the
% omnidirectional signal is computed
%
% Author: Sebastià V. Amengual
% Last modified: 12/19/18

SRIR_data.P_RIR = circshift(SRIR_data.P_RIR, -SRIR_data.OmniMicLag);

