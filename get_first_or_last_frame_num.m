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

function last_frame = get_first_or_last_frame_num(path_name, file_prefix, index_len, first_or_last)

% This function get last frame number automatically
% Input:
% path_name = the directory path
% file_prefix = the prefix of file name that contains the index number
% index_len = the length of frame index
% first_or_last = indicator; 
%                 'first' (default) - get first frame num;
%                 'last' - get last frame num 
%
% Output:
% last_frame = the index number of last frame

prefix_len = length(file_prefix);
if exist('first_or_last')
    if strcmp(first_or_last, 'first')
        files = ls(path_name);
    elseif strcmp(first_or_last, 'last')
        files = ls(path_name, '-r');
    else
        fprintf(1, 'ERROR! The input of ''first_or_last'' is wrong');
    end
else
    files = ls(path_name);
end
n = findstr(files, file_prefix);
number = files(n(1)+prefix_len:n(1)+prefix_len+index_len-1);
last_frame = uint16(str2num(number));