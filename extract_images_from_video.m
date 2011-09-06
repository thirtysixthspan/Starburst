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

function extract_images_from_video()

% This function extracts images into eye/ and scene/ directoty from the
% specified video

[sfname, spname] = uigetfile('*.mp4','Scene movie file');
sf = strcat(spname, sfname);

[efname, epname] = uigetfile('*.mp4','Eye movie file', spname);
ef = strcat(epname, efname);

eval(sprintf('!mkdir %s/Scene', spname));
eval(sprintf('!mkdir %s/Eye', epname));
eval(sprintf('!ffmpeg -i %s -img jpeg %sScene/Scene_%%5d.jpg', sf, spname));
eval(sprintf('!ffmpeg -i %s -img jpeg %sEye/Eye_%%5d.jpg', ef, epname));