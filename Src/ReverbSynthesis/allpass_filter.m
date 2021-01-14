% Copyright (c) Facebook, Inc. and its affiliates.

function y = allpass_filter(x, delay,  RT60, fs)

a_dB = -60*(delay/fs)/RT60;
a = 10^(a_dB/20);

for n=1:length(x)
    if n<delay+1
        y(n) = x(n);
    else
        y(n) = a*x(n) + x(n-delay) - a*y(n-delay);
    end
end

y = y';