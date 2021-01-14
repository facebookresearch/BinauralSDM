% Copyright (c) Facebook, Inc. and its affiliates.

function GCD = iscoprime(x) % assuming x is an array, 
    GCD = x(1);             % returning greatest common divisor for the array
    for i=1:size(x, 2)
        GCD = gcd(GCD, x(i));
    end
end