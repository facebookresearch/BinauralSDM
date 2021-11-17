% Copyright (c) Facebook, Inc. and its affiliates.

function fir_filter = create_FIR_eq(Gains, freqBands, fs)

N = 2^16;
A = db2mag(Gains);
F = freqBands/(fs/2);

if length(F) < 200
    A = [0 ; A ];
    F = [0 ; freqBands/(fs/2)];
    F_upsampled = logspace(0,log10(fs/2),200)/(fs/2);
    F_upsampled(1) = 0;
    F_upsampled(end) = 1;
    A_upsampled = interp1(F,A,F_upsampled,'linear');
else
    F_upsampled = F;
    A_upsampled = A;
end

d = fdesign.arbmag('N,F,A',N,F_upsampled,A_upsampled);
Hd = design(d,'freqsamp','SystemObject',true);
fir_filter = Hd.Numerator';
[~, fir_filter] = rceps(fir_filter);
