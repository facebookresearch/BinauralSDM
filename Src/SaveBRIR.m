% Copyright (c) Facebook, Inc. and its affiliates.

function SaveBRIR(SRIR_data, BRIR_data, DS_BRIR, early_BRIR, ER_BRIR, late_BRIR,ang)
% This function saves the BRIR dataset generated from the re-synthesis
% through SDM. 
% Input arguments:
%   - SRIR_data: Struct containing all the SRIR information (see
%   create_SRIR_data)
%   - BRIR_data: Struct containing BRIR information (see create_BRIR_data)
%   - DS_BRIR: Direct sound part of the BRIR
%   - early_BRIR: Early part of the BRIR (containing DS)
%   - ER_BRIR: Early reflections (without direct sound).
%   - late_BRIR: Angle independent late reverb tail.
%
%   Author: Sebastià V. Amengual
%   Last modified: 4/22/19

Save_Path = [BRIR_data.DestinationPath  regexprep(BRIR_data.HRTF_Subject,' ','_'), filesep SRIR_data.Room '_' SRIR_data.SourcePos '_' SRIR_data.ReceiverPos];

if ~exist([Save_Path filesep BRIR_data.RenderingCondition filesep], 'dir')
    mkdir([Save_Path filesep BRIR_data.RenderingCondition filesep]);
end

attenuation = db2mag(BRIR_data.Attenuation);

if max(max(abs(DS_BRIR)))/attenuation>1
    error(['The exported BRIRs are clipping! - The max value is' num2str(max(abs(DS_BRIR))/attenuation)]);
end

audiowrite([Save_Path filesep BRIR_data.RenderingCondition filesep 'az' num2str(ang(1)) 'el' num2str(ang(2)) '.wav'],early_BRIR./attenuation,BRIR_data.fs,'BitsPerSample',32);
audiowrite([Save_Path filesep BRIR_data.RenderingCondition filesep 'az' num2str(ang(1)) 'el' num2str(ang(2)) '_DS.wav'],DS_BRIR./attenuation,BRIR_data.fs,'BitsPerSample',32);
audiowrite([Save_Path filesep BRIR_data.RenderingCondition filesep 'az' num2str(ang(1)) 'el' num2str(ang(2)) '_ER.wav'],ER_BRIR./attenuation,BRIR_data.fs,'BitsPerSample',32);
audiowrite([Save_Path filesep BRIR_data.RenderingCondition filesep 'late_reverb.wav'],late_BRIR./attenuation,BRIR_data.fs,'BitsPerSample',32); 