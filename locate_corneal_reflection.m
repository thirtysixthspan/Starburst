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

function [x,y,ar] = locate_corneal_reflection(I, cx, cy, window_width)

% This function locates the corneal reflection within a window using an 
% adaptive thresholding technique.

% Input:
% I = input image
% [cx cy] = window center
% window_width = width of window (must be odd)
%
% Output:
% [x,y] = corneal reflection coordinate
% ar = approximate radius of the corneal reflection

if (mod(window_width,2)~=1)
 fprintf(1,'Window_width is not odd! It is set at %d!',window_width);
end;

[height width] = size(I);
i = 2;
score(1) = 0;
x = [];
y = [];
ar = [];

r = floor((window_width-1)/2);
sx = max(round(cx-r),1);
ex = min(round(cx+r),width);
sy = max(round(cy-r),1);
ey = min(round(cy+r),height);
Iw = I(sy:ey, sx:ex);

for threshold=max(max(I)):-1:1
    Iwt = Iw>=threshold;
    [labeled,numObjects] = bwlabel(Iwt,8);
    if numObjects < 2
        continue;
    end
    props = regionprops(labeled,'Area','Centroid','EquivDiameter');
    areas = [props.Area];
    max_area_index = find(areas == max(max(areas)));
    score(i) = areas(max_area_index(1))/(sum(areas)-areas(max_area_index(1)));
    if score(i) - score(i-1) < 0
        x = props(max_area_index(1)).Centroid(1);
        y = props(max_area_index(1)).Centroid(2);
        ar = props(max_area_index(1)).EquivDiameter / 2;
        break;
    end
    i = i+1;
end

if isempty(x)
   fprintf(1,'Sorry, no corneal reflection was found in this frame.\n');
   x = 0;
   y = 0;
   ar = 0;
   return;
end

x = x+sx-1;
y = y+sy-1;


