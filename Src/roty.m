% Copyright (c) Facebook, Inc. and its affiliates.

function rotmat = roty(beta)
% Rotation matrix around y-axis
% reimplemented to be independent of Phased Array System Toolbox

rotmat = [cosd(beta) 0 sind(beta); 0 1 0; -sind(beta) 0 cosd(beta)];

end
