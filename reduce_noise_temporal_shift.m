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

function [Ip, Cp] = reduce_noise_temporal_shift(I, C, beta)

% This function
% Input: 						Format:
% I = input image 				:	matrix
% C = normalization factor for each line 	:	column vector 
% beta = hysteresis factor
% Output: 						Format:
% Ip = output image 				:	matrix
% C = new normalization factor for each line 	:	column vector 


Cp = mean(I,2) * beta + C * (1-beta);
adjustment = (Cp - mean(I,2));
mat_adj = repmat(adjustment, [1 size(I,2)]);
mat_max = ones(size(I))*255;
Ip = min(double(I)+mat_adj, mat_max);
