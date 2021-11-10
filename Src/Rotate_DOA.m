% Copyright (c) Facebook, Inc. and its affiliates.

function SRIR_data = Rotate_DOA(SRIR_data, az_deg, el_deg)

% Apply rotations first around Z azis (azimuth rotation) and then around 
% Y axis (elevation rotation)
SRIR_data.DOA = (roty(el_deg) * rotz(-az_deg) * SRIR_data.DOA')';

end
