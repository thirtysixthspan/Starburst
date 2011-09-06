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

function [I] = remove_corneal_reflection(I, crx, cry, crr, angle_delta)

% Input:
% I = input image
% angle_delta = angle step size
% [crx cry] = corneal reflection center
% crr = corneal reflection radius
% Output:
% I = output image with the corneal reflection removed

if crx==0 | cry==0 | crr<=0
   return;
end

[height width] = size(I);

if crx-crr < 1 || crx+crr > width || cry-crr < 1 || cry+crr > height
    fprintf(1, 'Error! Corneal reflection is too near the image border\n');
    return;
end

theta=[0:pi/360:2*pi];
tmat = repmat(theta',[1 crr]);
rmat = repmat([1:crr],[length(theta) 1]);
[xmat,ymat]=pol2cart(tmat,rmat);
xv=reshape(xmat,[1 prod(size(xmat))]);
yv=reshape(ymat,[1 prod(size(ymat))]);

avgmat=ones(size(rmat))*mean(I(round(ymat(:,end)+cry)+(round(xmat(:,end)+crx)-1)*height));
permat=repmat(I(round(ymat(:,end)+cry)+(round(xmat(:,end)+crx)-1)*height),[1 crr]);
wmat=repmat((1:crr)/crr,[length(theta) 1]);
imat=avgmat.*(1-wmat) + permat.*(wmat); 
I(round(yv+cry)+(round(xv+crx-1).*height))=imat;
