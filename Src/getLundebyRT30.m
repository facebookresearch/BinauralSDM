% Copyright (c) Facebook, Inc. and its affiliates.

function [reverbTime, intersectionPoint, dirSoundLoc] = getLundebyRT30(roomIR, Fs, integrationWin, Tn)
%getLundebyRT calculates the truncated and energy compensated T30 using the
%Lundeby method (Acta Acoustica Vol. 81 1995)
%   getLundebyRT takes in a single channel (N,1) impulse response, the
%   sampling frequency, Fs, and an optional integration window parameter
%   and returns the reverberation time (T30) in seconds and the
%   intersection point in samples.
%
% Author: Peter Dodds (2019) with improvements to code based on ITA Toolbox 
% and the acmus matlab package. Reimplemented by Joshua Marcley (2019)
% using algorithm described in https://pdfs.semanticscholar.org/5841/897c265b08addf22dbfaa6da969875e376e4.pdf

    if nargin < 3
        blockSize = round(0.02*Fs);
        Tn = 30;
    elseif nargin == 3
        blockSize = round(Fs*integrationWin);
        Tn = 30;
    else
        blockSize = round(Fs*integrationWin);      
    end
    
    
    energyIR        = roomIR.*roomIR;
    numBlocks       = floor(length(energyIR)/blockSize);

    if numBlocks < 2
        numBlocks = 2;
    end
    
    smoothIR = zeros(1,numBlocks);
    smoothIR_dB = smoothIR;
   
    
    % Code below will detect sound events in continuous signal, i.e. it
    % WILL detect distortion artifcats in RIRs; however only the latest
    % sound event is "stored," therefore at the conclusion of the for loop
    % the only data of import will relate to the impulse response
    eNoise          = [];       % instantiate var to store noise energy
    ISE             = false;    % Is Sound Event bool
    noiseUp         = 5;       % this is a tuned parameter
    noiseDown       = 0;
    startSample     = 1;       % exclude first several block when energy is accumulating
    for n = startSample:numBlocks
        % Energy in this block
        e = mean(energyIR((n-1)*blockSize+1:n*blockSize));
        
        % Energy Level
        e_dB = 10*log10(e);
        
        % Store energy and energy level
        smoothIR(n) = e;
        smoothIR_dB(n) = e_dB;
        
        % instantiate noiseEst
        if n == startSample
            noiseEst = e_dB;
        end
        
        % Block is new sound event
        if e_dB > noiseEst + noiseUp && ~ISE
            ISE = true;
            segmentStart = n;
%             continue;
        % Block is continuing sound event
        elseif e_dB > noiseEst + noiseUp && ISE
%             continue;
        % Block is end of sound event
        elseif e_dB < noiseEst + noiseDown && ISE
            segmentEnd = n;
            ISE = false;
        end
        
        
        % Block is not in sound event
        if ~ISE
            % add block energy to noise energy
            eNoise(end+1) = e;
            
            % re-estimate noise level
            noiseEst = 10*log10(mean(eNoise));
        end
  
    end
    
%     plot(smoothIR_dB(segmentStart:segmentEnd))
    
    % Find index of maximum (not necessarily index of direct sound)
    [~,dirInd] = max(energyIR);
    
    % Find index of direct sound
    % First index BEFORE maximum that is greater than 30dB less than
    % maximum; This will fail in any instance in which the direct sound is
    % less than 30dB from the maximum
    samplesToCut = find(10*log10(energyIR(1:dirInd)) > 10*log10(energyIR(dirInd))-30,1,'first');
    
%     [slope, intercept] = linRegression(0:blockSize:((length(impulse_dB(samplesToCut:end))-1)*blockSize), impulse_dB(samplesToCut:end));    
%     %Calculate the energy compensation term
%     energyCompensation = max(energyIR)*10^(intercept/10)*exp(slope/10/log10(exp(1))*crossPoint)/(-slope/10/log10(exp(1)));

    %Calculate the T30 using compensated Schroeder integration
    upperLim = -5;
    lowerLim = (Tn + 5) * -1;

    if exist('segmentEnd','var')
        trimmedEnergy = energyIR(samplesToCut:segmentEnd*blockSize);
        schrCrv = cumsum(flipud(trimmedEnergy));
        schrCrv = schrCrv./max(schrCrv);
        schrCrv = flipud(schrCrv);
        schrCrv = real(10*log10(schrCrv));

        upperLimPt = find(schrCrv < upperLim,1,'first');
        lowerLimPt = find(schrCrv < lowerLim,1,'first');

        LS_y = schrCrv(upperLimPt:lowerLimPt);
        LS_n = length(LS_y);
        LS_x = (1:LS_n)';

        [rtSlope] = linRegression(LS_x, LS_y);

        reverbTime = -60/rtSlope/Fs; %T30
        intersectionPoint = (segmentEnd) * blockSize;
        dirSoundLoc = samplesToCut;
    
        % debug
%         subplot(1,2,1)
%         plot(schrCrv)
%         subplot(1,2,2)
%         plot(roomIR)
%         hold on
    else
        reverbTime = NaN;
    end
%    plot([intersectionPoint, intersectionPoint], [-20, 50])
%    plot([dirSoundLoc, dirSoundLoc], [-20, 50])
    
end

function [slope, intercept] = linRegression(x,y)

    mx = mean(x);
    my = mean(y);
    mx2 = mean(x.^2);
    mxy = mean(x.*y);

    intercept = (mx2*my-mx*mxy)/(mx2-mx^2);
    slope = (mxy - (mx*my))/(mx2-mx^2);

end
