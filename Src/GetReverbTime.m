% Copyright (c) Facebook, Inc. and its affiliates.

function [DesiredT30, OriginalT30, freqVector] = GetReverbTime(SRIR_data, preBRIR, bandsperoctave)

[DesiredT30, freqVector] = getLundebyFOB(SRIR_data.P_RIR, SRIR_data.fs,bandsperoctave);
DesiredT30 = DesiredT30';
freqVector = freqVector';

[UncorrectedLeftT30, ~] = getLundebyFOB(preBRIR(:,1), SRIR_data.fs,bandsperoctave);
[UncorrectedRightT30, ~] = getLundebyFOB(preBRIR(:,2), SRIR_data.fs,bandsperoctave);
OriginalT30 = mean([UncorrectedLeftT30' UncorrectedRightT30'],2);

end
