% Copyright (c) Facebook, Inc. and its affiliates.

function [RTs, fcentre] = getLundebyFOB(signal, Fs, bandsPerOctave, Tn)
% Returns the estimated Reverberation Time of a RIR in 1 or 1/3 octave
% bands.

minFreq = 62.5;
maxFreq = 20000;
snfft = 2*length(signal);
[~,g,~,f2] = oneOver_n_OctBandFilter(2*snfft, bandsPerOctave, Fs, minFreq , maxFreq);

if bandsPerOctave == 3
    fd = 2^(1/6);
elseif bandsPerOctave == 1
    fd = sqrt(2);
else
    error('Only 1 or 1/3 octave bands are currently supported')
end

fcentre = f2 / fd;

for iOb = 1 : size(g, 2)
    H_freq = fft(signal, 2*snfft);
    G = fft(g, 2*snfft);
    sigFilt = real(ifft(G(:, iOb) .* H_freq));
    RTs(iOb) = getLundebyRT30(sigFilt, Fs, 0.02, Tn);
end

end
