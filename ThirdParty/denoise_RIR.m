% Copyright (c) 2013, Densil Cabrera and Daniel Ricardo Jimenez Pinilla
% All rights reserved.

% Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

% * Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
% * Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
% * Neither the name of the University of Sydney nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

% THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
%
%

function OUT = denoise_RIR(IN, fs, hiF, loF, doplot)
% This function can be used on measured room impulse responses (RIRs) to
% extrapolate the decay envelope through the noise floor.
%
% It assumes an exponential decay and a steady state noise floor.
%
% Based on the de-noising technique described in:
% D. Cabrera, D. Lee, M. Yadav and W.L. Martens (2011) "Decay envelope
% manipulation of room impulse responses: Techniques for auralization and
% sonification," Australian Acoustical Society Conference, Gold Coast,
% Australia.
%
% This function is a little slow (test it first with a single channel room
% impulse respons, not too long, to get a feel for how long it will take to
% process a long multichannel impulse response).
%
% This function requires Matlab's curve fitting toolbox.
%
% Code by Densil Cabrera
% version 1.0 (13 October 2013)
%
% INPUT ARGUMENTS
%
% IN contains a room impulse response. If it is a structure, then it
% requires IN.audio (the room impulse response wave) and IN.fs (the audio
% sampling rate in Hz). If it is a structure, then the other input
% arguments are not used. If it is a vector or matrix containing the
% impulse response, then the other arguments are used.
%
% fs is audio sampling rate, which must be greater than 32 kHz
%
% numberofbands is a positive integer that specifies the number of octave
% bands that are treated independently. The highest octave band centre frequency is
% 'centred' on 16 kHz, but this is actually a highpass filter rather than
% bandpass.  The lowest filter is a lowpass filter. The default value is 8.
%
% The output y is the denoised RIR.
%
% Testimate is the estimated reverberation time of the curve-fitted
% denoised RIR
%
% T20 is reverberation time as conventionally defined over the -5 to -25 dB
% evaluation range after de-noising.

if nargin < 5, doplot = 0; end
if nargin < 4, loF = 125; end
if nargin < 3
    % dialog box for settings
    prompt = {'Highest octave filter frequency (Hz):', ...
        'Lowest octave filter frequency (Hz):', ...
        'Plot (0 | 1)'};
    dlg_title = 'Settings';
    num_lines = 1;
    def = {'16000', '125', '0'};
    answer = inputdlg(prompt,dlg_title,num_lines,def);
    
    if isempty(answer)
        OUT = [];
        return
    else
        hiF = str2num(answer{1,1});
        loF = str2num(answer{2,1});
        doplot = str2num(answer{3,1});
    end
end
if isstruct(IN)
    RIR = squeeze(IN.audio(:,:,1));
    fs = IN.fs;
else
    RIR = squeeze(IN(:,:,1));
    if nargin < 2
        fs = inputdlg({'Sampling frequency [samples/s]'},...
                           'Fs',1,{'48000'});
        fs = str2num(char(fs));
    end
end

if ~isempty(RIR) && ~isempty(fs) && ~isempty(hiF) && ~isempty(loF) && ~isempty(doplot)
    try
        if hiF > fs/2
            disp('High octave filter frequency is too high!')
            OUT = [];
            return
        end
        hiband = 3*round(10*log10(hiF)/3);
        loband = 3*round(10*log10(loF)/3);
        numberofbands = (hiband - loband)/3 + 1;

        % CHECK RIR DATA
        [len, chans] = size(RIR);
        Nyquist = fs/2; % Nyquist frequency

        % BAND NUMBERS
        bandnumbers = loband:3:hiband;
        fc = 10 .^ (bandnumbers ./ 10); % octave band centre frequency
        % commonly used nominal frequencies of the filters
        nominalfreq = round(fc);
        nominalfreq(nominalfreq==32) = 31.5;
        nominalfreq(nominalfreq==126) = 125;
        nominalfreq(nominalfreq==251) = 250;
        nominalfreq(nominalfreq==501) = 500;
        nominalfreq(nominalfreq==1995) = 2000;
        nominalfreq(nominalfreq==3981) = 4000;
        nominalfreq(nominalfreq==7943) = 8000;
        nominalfreq(nominalfreq==15849) = 16000;
        nominalfreq(nominalfreq>31.5) = round(nominalfreq(nominalfreq>31.5));
        disp(['Frequency      (Hz) ', num2str(nominalfreq)])

        % GENERATE FILTERS
        order = 4; % this effective filter order will be twice this due to filtfilt()
        % order must be even (recommend either 2 or 4).
        num = zeros(numberofbands,order+1);
        den = zeros(numberofbands,order+1);


        % use lowpass filter for bottom band
        f_hi = fc(1) * 10^0.15;
        Wn = f_hi/Nyquist;
        [num(1,:), den(1,:)] = butter(order, Wn, 'low');

        % use highpass filter for top band
        f_lo = fc(end) / 10^0.15;
        Wn = f_lo/Nyquist;
        [num(end,:), den(end,:)] = butter(order, Wn, 'high');

        if numberofbands > 2
            for k = 2:(numberofbands-1)
                f_hi = fc(k) * 10^0.15;
                f_low = fc(k) / 10^0.15;
                Wn = [f_low/Nyquist f_hi/Nyquist];
                [num(k,:), den(k,:)] = butter(order/2, Wn);
            end
        end

        % FILTER RIR INTO BANDS
        RIRoct = zeros(len, chans, numberofbands);
        for k = 1:numberofbands
            RIRoct(:,:,k) = filtfilt(num(k,:), den(k,:), RIR);
        end
        % preserve the original RIRoct for the chart
        RIRoct2=RIRoct;

        % derive a smoothed envelope function for each band
        lopassfreq = 4; % smoothing filter cutoff frequency in Hz
        halforder = 1; % smoothing filter order
        [num, den] = butter(halforder, lopassfreq/Nyquist, 'low');
        %envelopes = 10*log10(filtfilt(num, den, RIRoct .^2));
        envelopes = filtfilt(num, den, 10*log10(RIRoct .^2));
        % increased filter order for lower frequency bands
        if numberofbands>2
            for n = 2:numberofbands-1
                envelopes(:,:,1:end-n) = filtfilt(num, den, envelopes(:,:,1:end-n));
            end
        end
        envelopes = envelopes - repmat(max(envelopes),[len,1,1]); % make max = 0 dB
        % preallocate
        maxsample = zeros(1, chans, numberofbands);
        a = zeros(1, numberofbands);
        b = zeros(1, numberofbands);
        for ch = 1:chans
            for band = 1:numberofbands
                maxsample(ch,band) = find(envelopes(:,ch,band) == 0, 1, 'last');
                times = (0:length(envelopes) - maxsample(ch,band))./fs;
                s = fitoptions('Method','NonlinearLeastSquares',...
                    'Lower',[-1000,0],...
                    'Upper',[0,max(times)],...
                    'Startpoint',[1 1]);
                f = fittype('10*log10(10^(a*x/10)+b)','options',s);
                [c,gof] = fit(times',envelopes(maxsample(ch,band):end,ch,band),f);
                a(ch,band) = c.a;
                b(ch,band) = c.b;

                % remove noise floor by multiplying it with an exponential decay
                % function that matches that of the RIR decay

                % find the sample 10 dB above the curve-fitted noise floor - we will
                % start the process from this point
                noiseplus10dB = floor(((10*log10(b(ch,band))+10) ./ a(ch,band)) .* fs);

                % derive the signal to noise ratio (i.e., the deviation from ideal
                % decay)
                snr = (10.^(a(ch,band).*times./10) ./ (10.^(a(ch,band).*times./10) +b(ch,band))) .^ 0.5;

                % multiply the octave band RIR by the snr
                RIRoct2(noiseplus10dB+maxsample(ch,band):end,ch,band) = ...
                    RIRoct(noiseplus10dB+maxsample(ch,band):end,ch,band) .* snr(noiseplus10dB+1:end)';
            end
            Testimate = -60 ./ a; % reverberation time estimate based on curve-fitted function
            disp(['T   estimate   (s)  ', num2str(Testimate(ch,:))])

            % CALCULATE T20
            T = zeros(1,numberofbands);
            x = 20; % evaluation range for T20 in dB
            %Schroeder reverse integration
            for band = 1:numberofbands
                decaycurve = flipud(10*log10(cumsum(flipud(RIRoct2(:,ch,band).^2))+1e-300));
                % make IR start time 0 dB
                decaycurve = decaycurve - decaycurve(1);

                Tstart = find(decaycurve <= -5, 1, 'first'); % -5 dB
                Tend = find(decaycurve <= -x-5, 1, 'first'); % -x-5 dB
                p = polyfit((Tstart:Tend)', decaycurve(Tstart:Tend),1); %linear regression
                T(band) = 60/x*((p(2)-x-5)/p(1) - (p(2)-5)/p(1))/fs; % reverberation time
            end
            disp(['T20            (s)  ', num2str(T)]);

            % plots
            if doplot
                aspect = 0.5; % controls the aspect ratio of the subplot layout
                r = floor(numberofbands^aspect); % number of rows in the subplot layout
                c = ceil(numberofbands/r); % number of columns in the subplot layout

                figure('Name',['Channel ', num2str(ch)])
                peak = max(max(10*log10(RIRoct(:,ch).^2 +1e-300)));
                for band = 1:numberofbands
                    subplot(r,c,band)
                    plot((0:length(RIRoct)-1)./fs, ...
                        10*log10(RIRoct(:,ch,band).^2 +1e-300)-peak,...
                        'Color', [0.5 0.5 0.5])
                    hold on
                    plot((0:length(RIRoct2)-1)./fs, ...
                        10*log10(RIRoct2(:,ch,band).^2 +1e-300)-peak,'k')
                    ylim([-100 0])
                    xlim([0 (length(RIRoct)-1)/fs])
                    xlabel('Time (s)')
                    ylabel('Level (dB)')
                    title([num2str(nominalfreq(band)), ' Hz'])
                    text(length(RIRoct2)/3,-10,num2str(T(band)))
                    grid on
                    hold off
                end
            end % if doplot    
        end % channel loop

        % RECOMBINE OCTAVE BANDS
        y = sum(RIRoct2, 3);
        if isstruct(IN)
            OUT.audio = y;
            OUT.funcallback.name = 'denoise_RIR_by_extrapolation1.m';
            OUT.funcallback.inarg = {fs,hiF,loF,doplot};
        else
            OUT = y;
        end
    catch %sthgwrong
        OUT = [];
        warndlg('The input might be denoised already. Verify the audio input.','AARAE info')
    end
else
    OUT = [];
end
if doplot
    % play the modified RIR (normalized)
    sound(y ./ max(max(abs(y))),fs)
    aspect = 0.5; % controls the aspect ratio of the subplot layout
    r = floor(chans^aspect); % number of rows in the subplot layout
    c = ceil(chans/r); % number of columns in the subplot layout
    figure('Name','Broadband')
    for ch = 1:chans
        subplot(r,c,ch)
        plot((0:len-1)./fs,10*log10(RIR(:,ch).^2),'Color', [0.5 0.5 0.5])   
        hold on
        plot((0:len-1)./fs,10*log10(y(:,ch).^2),'k')
        title(['Channel ', num2str(ch)])
    end
end