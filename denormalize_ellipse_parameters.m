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

function [e] = denormalize_ellipse_parameters(ne,Hn)

% Input
% ne = ellipse parameters constructed using normalized points
% Hn = homography used to normalize the points

% Output
% e = denormalized ellipse parameters

e(1) = ne(1) / Hn(1,1);
e(2) = ne(2) / Hn(2,2);
e(3) = (ne(3) - Hn(1,3)) / Hn(1,1);
e(4) = (ne(4) - Hn(2,3)) / Hn(2,2);
e(5)=ne(5);
