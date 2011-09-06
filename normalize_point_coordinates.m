% Starburst Algorithm
%
% This source code is part of the starburst algorithm.
% Starburst algorithm is free; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 2 of the License, or
% (at your option) any later version.
%
% Starburst algorithm is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with cvEyeTracker; if not, write to the Free Software
% Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
%
%
% Starburst Algorithm - Version 1.0.0
% Part of the openEyes ToolKit -- http://hcvl.hci.iastate.edu/openEyes
% Release Date:
% Authors : Dongheng Li <donghengli@gmail.com>
%           Derrick Parkhurst <derrick.parkhurst@hcvl.hci.iastate.edu>
% Copyright (c) 2005
% All Rights Reserved.

function [nx, ny, H] = normalize_point_coordinates(x, y);

% Input:
% [x y] = coordinates (row vectors)

% Output:
% [nx ny] = normalized coordinates (row vectors)
% H = normalization homography

cx = mean(x);
cy = mean(y);
mean_dist = mean(sqrt(x.^2 + y.^2));
dist_scale = sqrt(2)/mean_dist;
H = [dist_scale     0            -dist_scale*cx;
     0              dist_scale   -dist_scale*cy;
     0              0            1];
nx = H(1,1)*x + H(1,3);
ny = H(2,2)*y + H(2,3);
