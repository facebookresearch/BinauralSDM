% Copyright (c) Facebook, Inc. and its affiliates.

function y = Schroeder_reverberator(x, comb_delays, comb_RT60, allpass_delays, allpass_RT, fs)

if ~iscoprime(comb_delays)
    error('the comb filter delays are not coprime!')
elseif ~iscoprime(allpass_delays)
    error('the all-pass filter delays are not coprime!')
end

for i=1:length(comb_delays)
    v(:,i) = comb_filter(x, comb_delays(i), comb_RT60(i),fs);
end

y_temp = sum(v,2);

for i=1:length(allpass_delays)
    y_temp = allpass_filter(y_temp, allpass_delays(i), allpass_RT(i),fs);
end

y = y_temp;