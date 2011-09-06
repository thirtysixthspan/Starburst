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

function [pupil_ellipse, cr_circle] = detect_pupil_and_corneal_reflection(I, sx, sy, edge_thresh)

% This function detects pupil and corneal reflection in the eye image
%
% Input:
% I = input image
% [sx sy] = start point for starburst algorithm
% edge_thresh = threshold for pupil edge detection
%
% Output:
% pupil_ellipse = 5-vector of the ellipse parameters of pupil
%   [a b cx cy theta]
%   a - the ellipse axis of x direction
%   b - the ellipse axis of y direction
%   cx - the x coordinate of ellipse center
%   cy - the y coordinate of ellipse center
%   theta - the orientation of ellipse
% cr_circle = 3-vector of the circle parameters of the corneal reflection
%   [crx cry crr]
%   crx - the x coordinate of circle center
%   cry - the y coordinate of circle center
%   crr - the radius of circle

sigma = 2;                      % Standard deviation of image smoothing
angle_delta = 1*pi/180;         % discretization step size (radians)
cr_window_size=301;             % corneal reflection search window size (about [sx,sy] center)
min_feature_candidates=10;      % minimum number of pupil feature candidates
max_ransac_iterations=10000;    % maximum number of ransac iterations
rays=18;                        % number of rays to use to detect feature points

I = gaussian_smooth_image(I, sigma);

[crx, cry, crar] = locate_corneal_reflection(I, sx, sy, cr_window_size);

crr = fit_circle_radius_to_corneal_reflection(I, crx, cry, crar, angle_delta);
crr = ceil(crr*2.5);

I = remove_corneal_reflection(I, crx, cry, crr, angle_delta);
cr_circle = [crx cry crr];

[epx, epy] = starburst_pupil_contour_detection(I, sx, sy, edge_thresh, rays, min_feature_candidates); 

if isempty(epx) || isempty(epy)
    pupil_ellipse = [0 0 0 0 0]';
    return;
end

[ellipse, inliers] = fit_ellipse_ransac(epx, epy, max_ransac_iterations);

[pupil_ellipse] = fit_ellipse_model(I, ellipse, angle_delta);

if ellipse(3) < 1 || ellipse(3) > size(I,2) || ellipse(4) < 1 || ellipse(4) > size(I,1)
    fprintf(1, 'Error! The ellipse center lies out of the image\n');
    pupil_ellipse = [0 0 0 0 0]';
end