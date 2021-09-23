% Copyright (c) Facebook, Inc. and its affiliates.

function SRIR_data = read_RIR(SRIR_data)
% This function reads RIRs from the specified location.
%
% It currently supports databases for the Eigenmike, Tetramic (48 kHz and
% 192 kHz), and FRL room acoustics array.
%
% Author: Sebastià V. Amengual
% Last modified: 12/19/18

switch upper(SRIR_data.MicArray)
    case 'EIGENMIKE'
        SRIR_data.P_RIR_Path = [SRIR_data.Database_Path 'Encoded_HOA' filesep SRIR_data.Room '_' SRIR_data.SourcePos '_' SRIR_data.ReceiverPos '_4HOA_N3D.wav'];
        SRIR_data.Raw_RIR_Path = [SRIR_data.Database_Path 'Raw32channels' filesep SRIR_data.Room '_' SRIR_data.SourcePos '_' SRIR_data.ReceiverPos '_Raw32channels.wav'];
        [SRIR_data.P_RIR, fs_P] = audioread(SRIR_data.P_RIR_Path);
        SRIR_data.P_RIR = SRIR_data.P_RIR(:,1);
        [SRIR_data.Raw_RIR, fs_Raw] = audioread(SRIR_data.Raw_RIR_Path);
        
    case 'TETRAMIC'
        if SRIR_data.fs == 48e3
            SRIR_data.P_RIR_Path = [SRIR_data.Database_Path 'Encoded_FOA' filesep SRIR_data.Room '_' SRIR_data.SourcePos '_' SRIR_data.ReceiverPos '_FOA_SN3D.wav'];
            SRIR_data.Raw_RIR_Path = [SRIR_data.Database_Path 'RawTetramic' filesep SRIR_data.Room '_' SRIR_data.SourcePos '_' SRIR_data.ReceiverPos '_RawTetramic48.wav'];             
        
        elseif SRIR_data.fs == 192e3
            SRIR_data.P_RIR_Path = [SRIR_data.Database_Path 'Encoded_FOA' filesep SRIR_data.Room '_' SRIR_data.SourcePos '_' SRIR_data.ReceiverPos '_FOA_SN3D192.wav'];
            SRIR_data.Raw_RIR_Path = [SRIR_data.Database_Path 'RawTetramic' filesep SRIR_data.Room '_' SRIR_data.SourcePos '_' SRIR_data.ReceiverPos '_RawTetramic192.wav'];              
        
        else
            error('Unhandled case for sampling frequncy of %f Hz.', SRIR_data.fs);
        end
        
        [SRIR_data.P_RIR, fs_P] = audioread(SRIR_data.P_RIR_Path);
        [SRIR_data.Raw_RIR, fs_Raw] = audioread(SRIR_data.Raw_RIR_Path);
        SRIR_data.P_RIR = SRIR_data.P_RIR(:,1);
        
    case 'FRL_5CM'
        SRIR_data.P_RIR_Path = [SRIR_data.Database_Path 'FRL_array' filesep SRIR_data.Room '_' SRIR_data.SourcePos '_' SRIR_data.ReceiverPos '_FRL5cm.wav'];        
        SRIR_data.Raw_RIR_Path = SRIR_data.P_RIR_Path;
        [SRIR_data.Raw_RIR, fs_Raw] = audioread(SRIR_data.Raw_RIR_Path);
        SRIR_data.P_RIR = SRIR_data.Raw_RIR(:,7);
        fs_P = fs_Raw;
        
    case 'FRL_10CM'
        SRIR_data.P_RIR_Path = [SRIR_data.Database_Path 'FRL_array' filesep SRIR_data.Room '_' SRIR_data.SourcePos '_' SRIR_data.ReceiverPos '_FRL10cm.wav'];        
        SRIR_data.Raw_RIR_Path = SRIR_data.P_RIR_Path;
        [SRIR_data.Raw_RIR, fs_Raw] = audioread(SRIR_data.Raw_RIR_Path);
        SRIR_data.P_RIR = SRIR_data.Raw_RIR(:,7);
        fs_P = fs_Raw;
        
    otherwise
        error('Invalid microhone array type "%s".', SRIR_data.MicArray);
end

if fs_P ~= fs_Raw || SRIR_data.fs ~= fs_Raw || SRIR_data.fs ~= fs_P
    error('Your sampling rates do not match! Check your SRIR struct or RIRs!');
else
    SRIR_data.fs = fs_P;
end

end
