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

function calculate_pupil_and_gaze()

% This function calculates the elliptical pupil parameters in the eye
% image and the preditive locacation of gaze in the scene image.
%
% The user need to specify the directory which contains the /Eye and /Scene image directory and the calibration
% file (calibration.mat). The user also need to eliminate bad calibration point correspondences  by click at the blue
% cross indicating the location of the corneal reflection). And then the program will calculate the gaze location
% in the scene image based.

pname = uigetdir(pwd,'Select Dir of data');
scene_file = sprintf('%s/Scene/Scene_', pname);
eye_file = sprintf('%s/Eye/Eye_', pname);
calibration_data_name = sprintf('%s/calibration.mat', pname);
ellipse_result_file = sprintf('%s/ellipse_result.mat', pname);
dat_file = sprintf('%s/ellipse_result.dat', pname);
pupil_edge_thresh = 20;
max_lost_count = 5;     % if consecutive lost tracking frame is more than this number, the start point is set to the center of the image

% Automatically get the frame number range
first_frame = get_first_or_last_frame_num(sprintf('%s/Eye/', pname), 'Eye_', 5, 'first');
last_frame = get_first_or_last_frame_num(sprintf('%s/Eye/', pname), 'Eye_', 5, 'last');
start_frame = first_frame+5;

% Eliminate the bad calibration points
load(sprintf('%s', calibration_data_name));
bad_cal_indices = [];
Is = read_image(scene_file, cal_frame(end));
Ie = read_gray_image(eye_file, cal_frame(end));
figure, 
subplot(1,2,1); imshow(uint8(Is)); hold on;
title({'Scene image:'; 'green cross: preditive gaze location'; 'Eye image:'; 'red cross: pupil center';
       'blue cross: corneal reflection'; 'yellow star(*): bad calibration correspondence (if any)'});
plot(cal_scene(:,1), cal_scene(:,2), 'g+');
while 1,
    subplot(1,2,2); imshow(uint8(Ie)); hold on;
    title(sprintf(' Instruction:\n left click on the blue cross to eliminate bad \n calibration point correspondence\n when you finish, click other button'));
    plot(cal_ellipse(:,3), cal_ellipse(:,4), 'r+');
    plot(cal_cr(:,1), cal_cr(:,2), 'b+');
    if ~isempty(bad_cal_indices)
        plot(cal_cr(bad_cal_indices,1), cal_cr(bad_cal_indices,2), 'y*');
    end
    [tx,ty,but] = ginput(1);
    if but == 1,
       dis = sqrt((cal_cr(:,1)-tx).^2 + (cal_cr(:,2)-ty).^2);
       min_dis_index = find(dis==min(dis), 1, 'first');
       bad_cal_indices = [bad_cal_indices min_dis_index];
    else
        break;
    end
end
bad_cal_indices = [bad_cal_indices 0]; % add a zero in order to eliminate the case of empty set
    
% while 1,
%     n = input('input the index of bad calibration points obtained by looking at the calibration.jpg (should be 1-9; 0-end input)\n');
%     if n >= 1 && n <= 9
%        bad_cal_indices = [bad_cal_indices n];
%     elseif n == 0
%         break;
%     else
%         fprintf('Error input! should be 1-9 or 0 to finish\n');
%     end
% end

% % Calculate the homography mapping matrix
% % Use the different vector between pupil center and corneal reflection
% [neye_x, neye_y, T1] = normalize_point_coordinates(cal_ellipse(:,3)-cal_cr(:,1), cal_ellipse(:,4)-cal_cr(:,2));
% [ncal_x, ncal_y, T2] = normalize_point_coordinates(cal_scene(:,1), cal_scene(:,2));
% A = zeros(2*length(ncal_x), 9);
% for i=1:length(ncal_x),
%     if i ~= bad_cal_indices
%         A(i*2-1,:) = [0 0 0 -neye_x(i) -neye_y(i) -1 ncal_y(i)*neye_x(i) ncal_y(i)*neye_y(i) ncal_y(i)];
%         A(i*2,:) = [neye_x(i) neye_y(i) 1 0 0 0 -ncal_x(i)*neye_x(i) -ncal_x(i)*neye_y(i) -ncal_x(i)];
%     end
% end
% [ua, sa, va] = svd(A);
% c = va(:,end);
% H_cr=reshape(c,[3,3])';
% H_cr=inv(T2)*H_cr*T1

% Calculate the second order polynomial parameters for the mapping
% Use the different vector between pupil center and corneal reflection
eye_x = cal_ellipse(:,3)-cal_cr(:,1);
eye_y = cal_ellipse(:,4)-cal_cr(:,2);
cal_x = cal_scene(:,1);
cal_y = cal_scene(:,2);
A = zeros(length(cal_x), 6);
for i=1:length(cal_x),
    if i ~= bad_cal_indices
        A(i,:) = [eye_y(i)^2 eye_x(i)^2 eye_y(i)*eye_x(i) eye_y(i) eye_x(i) 1];
    end
end
[ua, da, va] = svd(A);
b1 = ua'*cal_x;
b1 = b1(1:6);
par_x = va*(b1./diag(da));
b2 = ua'*cal_y;
b2 = b2(1:6);
par_y = va*(b2./diag(da));

frame_index = start_frame;
Ie5 = read_gray_image(eye_file, frame_index-5);
Ie4 = read_gray_image(eye_file, frame_index-4);
Ie3 = read_gray_image(eye_file, frame_index-3);
Ie2 = read_gray_image(eye_file, frame_index-2);
Ie1 = read_gray_image(eye_file, frame_index-1);
normalize_factor = (sum(Ie5,2) + sum(Ie4,2) + sum(Ie3,2) + sum(Ie2,2) + sum(Ie1,2))/(5*size(Ie1,2));
Ie = read_gray_image(eye_file, frame_index);
beta = 0.2;
[Ie, normalize_factor] = reduce_noise_temporal_shift(Ie, normalize_factor, beta);
fig_handle = figure, imshow(uint8(Ie));
title(sprintf('Please click near the pupil center'));
[cx, cy] = ginput(1);
close(fig_handle);

[height width] = size(Ie);
scene = zeros(last_frame, 2);
cr = zeros(last_frame, 3);
ellipse = zeros(last_frame, 5);
consecutive_lost_count = 0;

tic
for frame_index=start_frame:last_frame
    fprintf(1, '%d-', frame_index);
    if (mod(frame_index,30) == 0)
        fprintf(1, '\n');
    end

    Ie = read_gray_image(eye_file, frame_index);
    [Ie,normalize_factor] = reduce_noise_temporal_shift(Ie, normalize_factor, beta);
    [ellipse(frame_index,:), cr(frame_index,:)] = detect_pupil_and_corneal_reflection(Ie, cx, cy, pupil_edge_thresh);
    
    if ~(ellipse(frame_index,1) <= 0 || ellipse(frame_index, 2) <= 0)
        consecutive_lost_count = 0;
        cx = ellipse(frame_index, 3);
        cy = ellipse(frame_index, 4);
        
        % Calbulate the scene position using the different vector of pupil center and corneal reflection
        evx = cx-cr(frame_index,1);
        evy = cy-cr(frame_index,2);
        coef_vector = [evy^2 evx^2 evy*evx evy evx 1];
        scene(frame_index,:) = [coef_vector*par_x coef_vector*par_y];
        
        %scene_pos = H_cr*[cx-cr(frame_index,1) cy-cr(frame_index,2) 1]';
        %scene(frame_index,:) = [scene_pos(1)/scene_pos(3) scene_pos(2)/scene_pos(3)];
    else
        consecutive_lost_count = consecutive_lost_count + 1;
        if consecutive_lost_count >= max_lost_count,
            cx = width/2;
            cy = height/2;
        end
    end
end
toc
save(sprintf('%s', ellipse_result_file), 'ellipse', 'cr', 'scene');
save_eye_tracking_data(dat_file, ellipse, cr, scene);


function [I] = read_gray_image(file, index);
I = double(rgb2gray(imread(sprintf('%s%05d.jpg', file, index))));

function [I] = read_image(file, index);
I = double(imread(sprintf('%s%05d.jpg', file, index)));
