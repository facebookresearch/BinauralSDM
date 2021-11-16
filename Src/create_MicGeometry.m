% Copyright (c) Facebook, Inc. and its affiliates.

function micpos = create_MicGeometry(micArray)
% Returns the positions (in cartesian coordinates) of each capsule in the
% specified microphone array.
%  - Input arguments:
%           - micArray: String with array keyword: 'Tetramic', 'Eigenmike',
%           'FRL_5cm', 'FRL_10cm'.
%
% Author: Sebastià V. Amengual
% Last Modified: 4/29/19

switch micArray
    case 'Tetramic'
          micpos =  [0.0085    0.0085    0.0085 ; 
                     0.0085   -0.0085   -0.0085 ;
                    -0.0085    0.0085   -0.0085 ;
                    -0.0085   -0.0085    0.0085];
    case 'Eigenmike'
            % Mic positions according to mh acoustics documentation 
            % https://mhacoustics.com/sites/default/files/EigenmikeReleaseNotesV18.pdf
            % It requires transformation due to using a different coordinates system
            % https://mhacoustics.com/sites/default/files/EigenUnits%20User%20Manual.pdf

            % Azimuth and elevation are inverted

            micpos_sph =   [0 69; 32 90; 0 111; 328 90; 0 32; 45 55;...
                            69 90; 45 125; 0 148; 315 125; 291 90;... 
                            315 55; 91 21; 90 58; 90 121; 89 159;...
                            180 69; 212 90; 180 111; 148 90; 180 32;...
                            225 55; 249 90; 225 125; 180 148; 135 125;...
                            111 90; 135 55; 269 21; 270 58; 270 122;...
                            271 159];

            % Elevation starts from top (0) to bottom (180), while in Matlab convention
            % it's +90 (top) to -90 (bottom)
            micpos_sph(:,2) = 90-micpos_sph(:,2);
                
            % Converting to radians
            micpos_sph = micpos_sph*pi/180;
                
            % Radius is 4.2 cm
            micpos_sph(:,3) = 0.042;
                
            % Converting to cartesian coordinates
            [micpos(:,1), micpos(:,2), micpos(:,3)] = ...
            sph2cart(micpos_sph(:,1), micpos_sph(:,2), micpos_sph(:,3));
    case 'FRL_5cm'
        micpos = [1 0 0 ;
                  -1 0 0;
                  0 -0.7071 0.7071
                  0 0.7071 0.7071
                  0 -0.7071 -0.7071
                  0 0.7071 -0.7071
                  0 0 0]*0.046/2;
    case 'FRL_10cm'
        micpos = [1 0 0 ;
                  -1 0 0;
                  0 -0.7071 0.7071
                  0 0.7071 0.7071
                  0 -0.7071 -0.7071
                  0 0.7071 -0.7071
                  0 0 0]*0.096/2;
    case 'FRL_10cm_CustomPath'
        micpos = [1 0 0 ;
                 -1 0 0;
                 0 -0.7071 0.7071
                 0 0.7071 0.7071
                 0 -0.7071 -0.7071
                 0 0.7071 -0.7071
                 0 0 0]*0.096/2;
    otherwise
        error('You are trying to create the geometry of a non-existent array :(')
end


