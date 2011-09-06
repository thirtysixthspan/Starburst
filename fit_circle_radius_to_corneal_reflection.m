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

function r = fit_circle_radius_to_corneal_reflection(I, crx, cry, crar, angle_delta)

% This function uses a model-based minimization technique to find the radius at which the
% corneal reflection intensity profile is approximately at 1 standard deviation. It 
% requires the center and approximate radius of the corneal reflection to run.

% Input:
% I = input image
% [crx, cry] = location of the corneal reflection center
% crar = approximate radius of the corneal reflection 
% angle_delta = angle step size
%
% Output:
% r = optimized corneal reflection radius

r=[];

if crx==0 | cry==0 | crar==0
   return;
end

r  = fminsearch(@(r) circular_error(r, I, angle_delta, crx, cry), crar);

if r <= 0
    fprintf(1, 'Error! the radius of corneal reflection is 0\n');
    return;
end


function f = circular_error(r, I, angle_delta, crx, cry)
[height width] = size(I);
r_delta = 1;
f = 0;
Isum = 0;
Isum2 = 0.000001;
m = [0:angle_delta:(2*pi)];
cos_m = cos(m);
sin_m = sin(m);
for i = 1:size(m,2),
    x = crx + (r+r_delta) * cos_m(i);
    y = cry + (r+r_delta) * sin_m(i);
    x2 = crx + (r-r_delta) * cos_m(i);
    y2 = cry + (r-r_delta) * sin_m(i);
    if (x > 0 & y > 0 & x < width & y < height) & (x2 > 0 & y2 > 0 & x2 < width & y2 < height)
        Isum = Isum + double(I(ceil(y),ceil(x)));
        Isum2 = Isum2 + double(I(ceil(y2),ceil(x2)));
    end
end
f = (Isum / Isum2);

