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

function e = convert_conic_parameters_to_ellipse_parameters(c)

% This function converts conic parameters [c(1) c(2) c(3) c(4) c(5) c(6)
% to ellipse parameters [a b cx cy theta]

% Get ellipse orientation
theta = atan2(c(2),c(1)-c(3))/2;

% Get scaled major/minor axes
ct = cos(theta);
st = sin(theta);
ap = c(1)*ct*ct + c(2)*ct*st + c(3)*st*st;
cp = c(1)*st*st - c(2)*ct*st + c(3)*ct*ct;

% Get translations
T = [[c(1) c(2)/2]' [c(2)/2 c(3)]'];
t = -(2*T)\[c(4) c(5)]'; 
cx = t(1);
cy = t(2);

% Get scale factor
val = t'*T*t;
scale_inv = (val- c(6));

% Get major/minor axis radii
a = sqrt(scale_inv/ap);
b = sqrt(scale_inv/cp);

e = [a b cx cy theta];

if ~isreal(e)
    e = [0 0 0 0 0];
    return;
end

