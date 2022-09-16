% Copyright (c) Facebook, Inc. and its affiliates.

function rotmat = rotz(gamma)
% Rotation matrix around z-axis
% reimplemented to be independent of Phased Array System Toolbox

rotmat = [cosd(gamma) -sind(gamma) 0; sind(gamma) cosd(gamma) 0; 0 0 1];

end
