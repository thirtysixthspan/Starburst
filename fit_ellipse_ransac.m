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

function [max_ellipse, max_inlier_indices, ransac_iter] = fit_ellipse_ransac(x, y, maximum_ransac_iterations);

% Input
% [x,y] = feature points (row vectors)
% maximum_ransac_iterations 
%
% Output
% max_ellipse = best fitting ellipse parameters
% max_inlier_indices = inlier indices for max_ellipse

max_inliers = 0;
max_inlier_indices = [];
max_ellipse = [];
inliers_index = []; 
ninliers = 0;   
N = inf;         
ransac_iter = 0;   

if (isempty(x) | isempty(y))
  return;
end;

ep_num = length(x);
if (ep_num<5)
  fprintf(1,'Error! Must have at least 5 feature points to fit an ellipse\n');
  return
end;

[nx, ny, Hn] = normalize_point_coordinates(x, y);
dist_thres = sqrt(3.84)*Hn(1);
random_or_adaptive = 0;

ep = [nx; ny; ones(1,length(nx))]';

while N > ransac_iter
    if random_or_adaptive == 0
        % To ensure that 5 indices are different
        while 1
            random_indices = ceil(rand(5,1)*ep_num);
            rim = repmat(random_indices,[1 5]);
            if (sum(sum(rim==rim'))==5)
                break;
            end;
        end;
        % Calculate the ellipse from random selected points
        nxi=nx(random_indices);
        nyi=ny(random_indices);
    else
        % Calculate the ellipse from inliers of previous iteration
        nxi=nx(max_inlier_indices);
        nyi=ny(max_inlier_indices);
    end
    A = [nxi.*nxi; nxi.*nyi; nyi.*nyi; nxi; nyi; ones(1,length(nxi))]';
    
    [ua, sa, va] = svd(A);
    nconic_par = va(:,end);
    nconic_matrix = [nconic_par(1) nconic_par(2)/2 nconic_par(4)/2; 
                    nconic_par(2)/2 nconic_par(3) nconic_par(5)/2; 
                    nconic_par(4)/2 nconic_par(5)/2 nconic_par(6)];
    diserr = sum((ep*nconic_matrix).*ep, 2);
    inliers_index = find(abs(diserr) < dist_thres);
    ninliers = length(inliers_index);
    
    random_or_adaptive = 0;
    if ninliers > max_inliers
        nellipse_par = convert_conic_parameters_to_ellipse_parameters(nconic_par);
        if isreal(nellipse_par) && nellipse_par(1) > 0 && nellipse_par(2) > 0 
            ellipse_par=denormalize_ellipse_parameters(nellipse_par,Hn);
            er=ellipse_par(1)/ellipse_par(2);
            if (er>0.75 && er<1.34)
                max_inliers = ninliers;
                max_inlier_indices = inliers_index;
                max_ellipse=ellipse_par;
                N = log(1-0.99)/log(1-(ninliers/ep_num)^5+eps); % plus eps, in order to avoid log(0)
                random_or_adaptive = 1;
            end
        end
    end
    
    ransac_iter = ransac_iter+1;
    if (ransac_iter > maximum_ransac_iterations)
        fprintf(1, 'Attention! The maximum number of ransac iterations exceeded!\n');
        break;
    end
end

