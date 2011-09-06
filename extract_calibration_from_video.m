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

function extract_calibration_from_video();

% This function extraction the data of calibration for eye tracker.
%
% The user need to specify the directory which contains the /Eye and /Scene image directory. The left
% and right mouse button can be used to browse the images. When the eye is fixing at one of the calibration
% point, the user can indicat the calibration point in the scene image and indicate the start point in
% the eye image. And then the program will highlight the pupil ellipse and the corneal reflection. After
% confirmation of the user, that calibration point correspondence is added. Finally, a file (calibration.mat)
% containing the calibration data and an image (calibration.jpg) of calibration point correspondences will
% be saved in the current directory automatically.

pname = uigetdir(pwd,'Select Dir to save calibration data');
eye_file = sprintf('%s/Eye/Eye_', pname);
scene_file = sprintf('%s/Scene/Scene_', pname);
calibration_data_name = sprintf('%s/calibration.mat', pname);
calibration_image_name = sprintf('%s/calibration.jpg', pname);

beta = 0.2;         % the parameter for noise reduction
frame_step = 5;     % the frame step for browsing

% Automatically get the frame number range
first_frame = get_first_or_last_frame_num(sprintf('%s/Eye/', pname), 'Eye_', 5, 'first');
last_frame = get_first_or_last_frame_num(sprintf('%s/Eye/', pname), 'Eye_', 5, 'last');
frame_index = first_frame+5;

Ie5 = read_gray_image(eye_file, frame_index-5);
Ie4 = read_gray_image(eye_file, frame_index-4);
Ie3 = read_gray_image(eye_file, frame_index-3);
Ie2 = read_gray_image(eye_file, frame_index-2);
Ie1 = read_gray_image(eye_file, frame_index-1);
normalize_factor = (sum(Ie5,2) + sum(Ie4,2) + sum(Ie3,2) + sum(Ie2,2) + sum(Ie1,2))/(5*size(Ie1,2));
Ie = read_gray_image(eye_file, frame_index);
[Ie, normalize_factor] = reduce_noise_temporal_shift(Ie, normalize_factor, beta);

Is = read_image(scene_file, frame_index);
handle = figure, subplot(1,2,1); imshow(uint8(Is));
title({'Instruction:'; sprintf('left button=next %d frame', frame_step); ...
       sprintf('right button=previous %d frame', frame_step); 'middle button=indicate calibration point in scene';});

subplot(1,2,2); imshow(uint8(Ie));
title(sprintf('frame %d (last frame:%d)', frame_index, last_frame));

fprintf(1,'Instruction:\n left button=next frame\n middle button=select calibration point\n right button=previous frame\n');

left_button=1;
middle_button=2;
right_button=3;

cal_frame = zeros(9,1);
cal_scene = zeros(9,2);
cal_cr = zeros(9,3);
cal_ellipse = zeros(9,5);
cal_index = 1;
browse_or_auto_next = 1;    % indicator: 1-use mouse click to browse images; 0-auto browse next frame
while cal_index <= 9,
    if browse_or_auto_next == 1
        [x, y, button] = ginput(1);
    else
        button = left_button;
        browse_or_auto_next = 1;
    end
    if button == middle_button
        cal_frame(cal_index) = frame_index;
        cal_scene(cal_index, 1) = x;
        cal_scene(cal_index, 2) = y;
        hold on;
        plot(x, y, 'g+');
        
        title({'Instruction:'; 'Please click near pupil center in the eye image'});
        [cx, cy] = ginput(1);
        [cal_ellipse(cal_index,:), cal_cr(cal_index,:)] = detect_pupil_and_corneal_reflection(Ie, cx, cy, 20);
        if uint16(cal_ellipse(cal_index,1)) <= 0 || uint16(cal_ellipse(cal_index, 2)) <= 0
            title({'ERROR! Ellipse parameter:';
                   sprintf('major-minor axis(%4.1f,%4.1f); center(%4.1f,%4.1f); angle(%4.1f)', ...
                   cal_ellipse(cal_index,1), cal_ellipse(cal_index,2), cal_ellipse(cal_index,3), cal_ellipse(cal_index,4), cal_ellipse(cal_index,5))});
        else
            title(sprintf('Instruction:\n Left button=ellipse is correct\n Other wise=ellipse is wrong, selete another frame'));
            plot(cal_ellipse(:,3), cal_ellipse(:,4), 'g+');
            plot(cal_cr(:,1), cal_cr(:,2), 'b+');
            [x, y, button] = ginput(1);      
            if button == 1
                cal_index = cal_index+1;
            else
                cal_scene(cal_index,:) = zeros(1,2);
                cal_cr(cal_index,:) = zeros(1,3);
                cal_ellipse(cal_index,:) = zeros(1,5);
            end
            browse_or_auto_next = 0;
        end
    else
        Is = [];
        Ie = [];
        if button == left_button
            if frame_index+frame_step > last_frame
                fprintf('ERROR! frame index exceed (%d-%d)\n', first_frame, last_frame);
                title(sprintf('ERROR! frame index exceed (%d-%d)', first_frame, last_frame));
                continue;
            end
            frame_index = frame_index+frame_step;
        else
            if frame_index-frame_step < first_frame
                fprintf('ERROR! frame index exceed (%d-%d)\n', first_frame, last_frame);
                title(sprintf('ERROR! frame index exceed (%d-%d)', first_frame, last_frame));
                continue;
            end
            frame_index = frame_index-frame_step;
        end;
        
        Ie = read_gray_image(eye_file, frame_index);
        [Ie, normalize_factor] = reduce_noise_temporal_shift(Ie, normalize_factor, beta);
        Is = read_image(scene_file, frame_index);
        
        subplot(1,2,2); imshow(uint8(Ie)); hold on;
        if cal_index > 1
            plot(cal_ellipse(:,3), cal_ellipse(:,4), 'g+');
            plot(cal_cr(:,1), cal_cr(:,2), 'b+');
        end
        title(sprintf('frame %d (last frame:%d)', frame_index, last_frame));
        
        subplot(1,2,1); imshow(uint8(Is)); hold on;
        if cal_index > 1
            plot(cal_scene(:,1), cal_scene(:,2), 'g+');
        end
        title({'Instruction:'; sprintf('left button=next %d frame', frame_step); ...
               sprintf('right button=previous %d frame', frame_step); 'middle button=indicate calibration point in scene';});
     end;
end

save(sprintf('%s', calibration_data_name),'cal_scene', 'cal_ellipse', 'cal_cr', 'cal_frame');
print(handle, '-djpeg', sprintf('%s', calibration_image_name));




function [I] = read_gray_image(file, index);
I = double(rgb2gray(imread(sprintf('%s%05d.jpg', file, index))));

function [I] = read_image(file, index);
I = double(imread(sprintf('%s%05d.jpg', file, index)));

