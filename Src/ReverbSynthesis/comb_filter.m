% Copyright (c) Facebook, Inc. and its affiliates.

function y = comb_filter(x, delay, RT60, fs)

b = 1;
a_dB = -60*(delay/fs)/RT60;
a = 10^(a_dB/20);

for n=1:length(x)
    if n<delay+1
        y(n) = x(n);
    else
        y(n) = x(n) - a*y(n-delay);
    end
end

