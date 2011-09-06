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

function I = plot_ellipse_in_image(I, v, ellipse_color);

% This function plots the ellipse in the image
% Input:
% I = input image; can be color image (3 bits) or gray image (1 bit)
% v = ellipse parameters
% ellipse_color = 
%
% Output:
% I = output image with the red ellipse and the center

[height width bit] = size(I);
ellipse_a = v(1);
ellipse_b = v(2);
cx = v(3);
cy = v(4);
ellipse_theta = v(5);

t = 0:pi/360:2*pi;
x = ellipse_a*cos(t);
y = ellipse_b*sin(t);
X = ceil(x*cos(ellipse_theta) - y*sin(ellipse_theta) + cx);
Y = ceil(x*sin(ellipse_theta) + y*cos(ellipse_theta) + cy);
index = find((X >= 1) & (X <= width) & (Y >= 1) & (Y <= height));

cx = ceil(cx);
cy = ceil(cy);

if bit == 3
    if ~exist('ellipse_color')
        ellipse_color = [0 255 0];
    elseif length(ellipse_color) ~= 3
        ellipse_color = [0 255 0];
    end
    
    I((X(index)-1)*height+Y(index)) = ellipse_color(1);
    I((X(index)-1)*height+Y(index)+width*height) = ellipse_color(2);
    I((X(index)-1)*height+Y(index)+2*width*height) = ellipse_color(3);
    % draw a cross to indication the ellipse center
    if cy > 11 & height - cy > 11 & cx > 11 & width - cx > 11
        I(cy,cx-11:cx+11,1) = ellipse_color(1);
        I(cy,cx-11:cx+11,2) = ellipse_color(2);
        I(cy,cx-11:cx+11,3) = ellipse_color(3);
        I(cy-11:cy+11, cx, 1) = ellipse_color(1);
        I(cy-11:cy+11, cx, 2) = ellipse_color(2);
        I(cy-11:cy+11, cx, 3) = ellipse_color(3);
    end
elseif bit == 1
    if ~exist('ellipse_color')
        ellipse_color = 255;
    elseif length(ellipse_color) ~= 1
        ellipse_color = 255;
    end
    
    I((X(index)-1)*height+Y(index)) = ellipse_color;
    % draw a cross to indication the ellipse center
    if cy > 11 & height - cy > 11 & cx > 11 & width - cx > 11
        I(cy,cx-11:cx+11,1) = ellipse_color;
        I(cy-11:cy+11, cx, 1) = ellipse_color;
    end
end