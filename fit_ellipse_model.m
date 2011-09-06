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

function [fit_ellipse] = fit_ellipse_model(I, ellipse, angle_delta)

% This function does an iterative gradient descent looking for an
% ellipse defined by a dark region on the interior and a light
% region on the exterior.

% Input
% I = input image
% ellipse = ellipse parameters (row vector)
% angle_delta = discretization step size of ellipse (radians)
%
% Output
% fit_ellipse = ellipse parameters (row vectors)

fit_ellipse=[];

if (isempty(ellipse))
  return;
end;

fit_ellipse = fminsearch(@(v) minfunc(v, I, angle_delta), ellipse);


function f = minfunc(v, I, angle_delta)

[height width] = size(I);
a = v(1);
b = v(2);
cx = v(3);  
cy = v(4);
ellipse_theta = v(5);
r_delta = 1;
f = 0;
Isum = 0;
Isum2 = 0.000001;
m = [0:angle_delta:(2*pi)];
cos_m = cos(m);
sin_m = sin(m);
rc = abs(cos_m.*r_delta);
rs = abs(sin_m.*r_delta);
for i = 1:size(m,2),
    x = (a+rc(i)) * cos_m(i);
    y = (b+rs(i)) * sin_m(i);
    xr = x*cos(ellipse_theta) - y*sin(ellipse_theta) + cx;
    yr = x*sin(ellipse_theta) + y*cos(ellipse_theta) + cy;
    if (xr > 0 & yr > 0 & xr <= width & yr <= height)
        x2 = (a-rc(i)) * cos_m(i);
        y2 = (b-rs(i)) * sin_m(i);
        xr2 = x2*cos(ellipse_theta) - y2*sin(ellipse_theta) + cx;
        yr2 = x2*sin(ellipse_theta) + y2*cos(ellipse_theta) + cy;
        if (xr2 > 0 & yr2 > 0 & xr2 <= width & yr2 <= height)
            Isum = Isum + double(I(ceil(yr),ceil(xr)));
            Isum2 = Isum2 + double(I(ceil(yr2),ceil(xr2)));
        end
    end
end
f = -(Isum / Isum2);
