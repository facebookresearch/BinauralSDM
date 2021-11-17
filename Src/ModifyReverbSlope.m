% Copyright (c) Facebook, Inc. and its affiliates.

function EqBRIR = ModifyReverbSlope(BRIR_Data,BRIR_TimeData, OriginalT60, DesiredT60, FreqVector)
% This function decomposes a BRIR into several bands and modifies the decay
% slope of each band according to the input parameters.
%
%   Input parameters:
%       - BRIR_data: Struct containing a BRIR and its information.
%       - OriginalT60: Reverberation time of the input BRIR [N x 1],
%       being N the number of bands.
%       - DesiredT60: Reverberation time of the reference RIR [N x 1], 
%       being N the number of bands.
%       - bandsperoctave: Number of bands per octave in the slope
%       manipulation process (integer).
%       - FreqVector: Frequencies of the reverberation times included in
%       OriginalT60 and DesiredT60 [N x 1].
%
%   Output parameters:
%       - EqBRIR: BRIR with the modified reverb slope.
%
%   Author: Sebastia V. Amengual
%   Last modified: 04/15/2019

% Need to regenerate the filterbank in case the corrected BRIR is longer
% than the mixing time (special case for the late reverb tail).
if length(BRIR_TimeData) > length(BRIR_Data.FilterBank_g)
    BRIR_Data.FilterBank_snfft = length(BRIR_TimeData);
    [BRIR_Data.G,BRIR_Data.FilterBank_g,BRIR_Data.FilterBank_f1,BRIR_Data.FilterBank_f2] = ...
        oneOver_n_OctBandFilter(2*BRIR_Data.FilterBank_snfft, BRIR_Data.BandsPerOctave,...
        BRIR_Data.fs, BRIR_Data.FilterBank_minFreq , BRIR_Data.FilterBank_maxFreq);
end


numOfBands = length(BRIR_Data.FilterBank_f1);
EqBRIR = zeros(size(BRIR_TimeData));

% freq_idx = find(FreqVector < BRIR_Data.FilterBank_f2(1),1,'last');
% last_freq_idx = find(FreqVector >= BRIR_Data.FilterBank_f2(end),1,'first');
% OriginalT60 = OriginalT60(freq_idx:last_freq_idx);
% 
% DesiredT60 = DesiredT60(freq_idx:last_freq_idx);

d0 = log(1e6)./(2*OriginalT60);
d1 = log(1e6)./(2*DesiredT60);

d0(isnan(d1)) = 0;
d0(isnan(d0)) = 0;
d1(isnan(d0)) = 0;
d1(isnan(d1)) = 0;

H_freq = fft(BRIR_TimeData,2*BRIR_Data.FilterBank_snfft);
G = fft(BRIR_Data.FilterBank_g,2*BRIR_Data.FilterBank_snfft);


for band = 1:numOfBands
    % Filter the result with octave band filter
    
    y = real(ifft(G(:,band).*H_freq));

    y = y(BRIR_Data.FilterBank_snfft+1:end,:);
    H_filt = y(1:BRIR_Data.FilterBank_snfft,:);
    
    H_corrected = H_filt.*exp(-(0:BRIR_Data.FilterBank_snfft-1)'/BRIR_Data.fs.*(d1(band)-d0(band))); % changing reverb slope
        
    EqBRIR = EqBRIR + H_corrected;
    
end


end