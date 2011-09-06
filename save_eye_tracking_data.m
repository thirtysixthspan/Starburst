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

function save_eye_tracking_data(file_name, ellipse, cr, scene)

% This function saves the eye tracking data including the parameters of
% pupil ellipse, the corneal reflection and the preditive gaze location in
% scene to a text file.
%
% Input:
% file_name = the file name of the data file include the path
% ellipse = the parameters of pupil ellipse
% cr = the corneal reflection
% scene = preditive gaze location in scene 

fid = fopen(file_name, 'w');
if fid == -1
    fprintf(1, 'Error! can not open the file %s', file_name);
    return;
end

fprintf(fid, 'index  pupil(a)  pupil(b)  pupil(cx)  pupil(cy)  pupil(theta)  cr(cx)  cr(cy)  cr(r)  scene(x)  scene(y)\n');

for i=1:size(cr,1)
    fprintf(fid, '%5d  %8.2f  %8.2f  %9.2f  %9.2f  %12.2f %7.2f %7.2f %6.1f  %8.2f  %8.2f\n', ...
        i, ellipse(i,1), ellipse(i,2), ellipse(i,3), ellipse(i,4), ellipse(i,5), cr(i,1), cr(i,2), cr(i,3), scene(i,1), scene(i,2));
end
fclose(fid);