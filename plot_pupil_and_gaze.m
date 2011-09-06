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

function plot_pupil_and_gaze()

% This function plots the pupil ellipse and its center on the eye image and
% plots the gaze location in the scene image. And then these tow image form
% the result image saved in ./Result/ directory.

pname = uigetdir(pwd,'Select Dir of data');
eval(sprintf('!mkdir %s/Result', pname));
eval(sprintf('!mkdir %s/Result_Eye', pname));
eval(sprintf('!mkdir %s/Result_Scene', pname));
eval(sprintf('!mkdir %s/Result_Small_Eye', pname));
eye_file = sprintf('%s/Eye/Eye_', pname);
scene_file = sprintf('%s/Scene/Scene_', pname);
image_result_file = sprintf('%s/Result/result_', pname);
eye_result_file = sprintf('%s/Result_Eye/result_', pname);
scene_result_file = sprintf('%s/Result_Scene/result_', pname);
small_eye_result_file = sprintf('%s/Result_Small_Eye/result_', pname);
ellipse_result_file = sprintf('%s/ellipse_result.mat', pname);

% Automatically get the frame number range
first_frame = get_first_or_last_frame_num(sprintf('%s/Eye/', pname), 'Eye_', 5, 'first');
last_frame = get_first_or_last_frame_num(sprintf('%s/Eye/', pname), 'Eye_', 5, 'last');
start_frame = first_frame+5;

load(ellipse_result_file);
cr = round(cr);
scene = round(scene);

cross_len = 15;
cross_len_eye = 11;
red = [255 0 0];
green = [0 255 0];
blue = [0 0 255];

Is = read_image(scene_file, start_frame); 
[height width bit] = size(Is);
small_eye_ratio = 0.25;
small_h = uint16(height*small_eye_ratio);
small_w = uint16(width*small_eye_ratio);
Ir = uint8(zeros(size(Is)));

tic
for frame_index=1:last_frame
    fprintf(1, '%d-', frame_index);
    if (mod(frame_index,30) == 0)
        fprintf(1, '\n');
    end
    Is = read_image(scene_file, frame_index);
    Ie = read_image(eye_file, frame_index);    
    
    % The image index must start at least from 4 using ffmpeg to convert
    % jpeg to mpeg
    if frame_index >= start_frame 
        %plot the corneal reflection
        if cr(frame_index,1) >= cross_len_eye+2 & cr(frame_index,1) <= width-cross_len_eye-1 & ...
                cr(frame_index,2) >= cross_len_eye+2 & cr(frame_index,2) <= height-cross_len_eye-1
            for bit = 1:3
                Ie(cr(frame_index,2),cr(frame_index,1)-cross_len_eye:cr(frame_index,1)+cross_len_eye, bit) = red(bit);
                Ie(cr(frame_index,2)-cross_len_eye:cr(frame_index,2)+cross_len_eye, cr(frame_index,1), bit) = red(bit);

                Ie(cr(frame_index,2)+1,cr(frame_index,1)-cross_len_eye:cr(frame_index,1)+cross_len_eye, bit) = red(bit);
                Ie(cr(frame_index,2)-cross_len_eye:cr(frame_index,2)+cross_len_eye, cr(frame_index,1)+1, bit) = red(bit);

                Ie(cr(frame_index,2)-1,cr(frame_index,1)-cross_len_eye:cr(frame_index,1)+cross_len_eye, bit) = red(bit);
                Ie(cr(frame_index,2)-cross_len_eye:cr(frame_index,2)+cross_len_eye, cr(frame_index,1)-1, bit) = red(bit);
            end
        end

        % plot the gaze position using the different vector of pupil center and
        % corneal reflection
        if scene(frame_index,1) >= cross_len+2 & scene(frame_index,1) <= width-cross_len-1 & ...
                scene(frame_index,2) >= cross_len+2 & scene(frame_index,2) <= height-cross_len-1
            for bit = 1:3
                Is(scene(frame_index,2),scene(frame_index,1)-cross_len:scene(frame_index,1)+cross_len,bit) = green(bit);
                Is(scene(frame_index,2)-cross_len:scene(frame_index,2)+cross_len, scene(frame_index,1),bit) = green(bit);

                Is(scene(frame_index,2)-1,scene(frame_index,1)-cross_len:scene(frame_index,1)+cross_len,bit) = green(bit);
                Is(scene(frame_index,2)-cross_len:scene(frame_index,2)+cross_len, scene(frame_index,1)-1,bit) = green(bit);

                Is(scene(frame_index,2)+1,scene(frame_index,1)-cross_len:scene(frame_index,1)+cross_len,bit) = green(bit);
                Is(scene(frame_index,2)-cross_len:scene(frame_index,2)+cross_len, scene(frame_index,1)+1,bit) = green(bit);
            end
        end

        % plot the ellipse
        if ellipse(frame_index,3) ~= 0 & ellipse(frame_index,4) ~= 0
            Ie = plot_ellipse_in_image(Ie, ellipse(frame_index,:));
            Ie = plot_ellipse_in_image(Ie, [ellipse(frame_index,1) ellipse(frame_index,2) ellipse(frame_index,3)+1 ellipse(frame_index,4)+1 ellipse(frame_index,5)]);
            Ie = plot_ellipse_in_image(Ie, [ellipse(frame_index,1) ellipse(frame_index,2) ellipse(frame_index,3)-1 ellipse(frame_index,4)+1 ellipse(frame_index,5)]);
            Ie = plot_ellipse_in_image(Ie, [ellipse(frame_index,1) ellipse(frame_index,2) ellipse(frame_index,3)+1 ellipse(frame_index,4)-1 ellipse(frame_index,5)]);
            Ie = plot_ellipse_in_image(Ie, [ellipse(frame_index,1) ellipse(frame_index,2) ellipse(frame_index,3)-1 ellipse(frame_index,4)-1 ellipse(frame_index,5)]);
        end
    end
    imwrite(uint8(Ie), sprintf('%s%05d.jpg', eye_result_file, frame_index));
    imwrite(uint8(Is), sprintf('%s%05d.jpg', scene_result_file, frame_index));
    Ie_small = imresize(Ie, small_eye_ratio);
    Is_result = Is;
    Is_result(1:small_h, 1:small_w, :) = Ie_small(1:small_h, 1:small_w, :);
    imwrite(uint8(Is_result), sprintf('%s%05d.jpg', small_eye_result_file, frame_index));
    
    Ir_tmp = [uint8(imresize(Is,0.5)) uint8(imresize(Ie,0.5))];
    Ir(uint16(height*0.25):uint16(height*0.75)-1, :, :) = Ir_tmp(1:uint16(height*0.5), :, :);
    imwrite(Ir, sprintf('%s%05d.jpg', image_result_file, frame_index));
end
toc

eval(sprintf('!ffmpeg -i %s%%05d.jpg -b 16000 %s/eye_result.mpg', eye_result_file, pname));
eval(sprintf('!ffmpeg -i %s%%05d.jpg -b 16000 %s/scene_result.mpg', scene_result_file, pname));
eval(sprintf('!ffmpeg -i %s%%05d.jpg -b 16000 %s/small_eye_result.mpg', small_eye_result_file, pname));
eval(sprintf('!ffmpeg -i %s%%05d.jpg -b 16000 %s/equal_size_result.mpg', image_result_file, pname));



function [I] = read_gray_image(file, index);
I = double(rgb2gray(imread(sprintf('%s%05d.jpg', file, index))));

function [I] = read_image(file, index);
I = double(imread(sprintf('%s%05d.jpg', file, index)));
