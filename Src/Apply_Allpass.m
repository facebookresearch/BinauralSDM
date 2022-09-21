% Copyright (c) Facebook, Inc. and its affiliates.

function BRIR_late = Apply_Allpass(BRIR_late, BRIR_data)

disp('Started applying allpass to late reverberation')
fprintf('Applying %d allpass filters.\n', length(BRIR_data.allpass_delays));

for ap = 1 : length(BRIR_data.allpass_delays)
    for ear = 1 : size(BRIR_late, 2)
        BRIR_late(:, ear) = allpass_filter(BRIR_late(:, ear), ...
            BRIR_data.allpass_delays(ap), BRIR_data.allpass_RT(ap), BRIR_data.fs);
    end
end

fprintf('\n');

end
