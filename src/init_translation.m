%% Lagadic Team -- Inria Sophia Antipolis
%  Renato Martins 2017
%  Email: renatojmsdh@gmail.com
%
%  Use: function which finds the overlapped regions after performing the derotation.
%  Inputs: - D_ref (vector n x 1): the reference depth (before de-rotation)
%          - D_cur (vector n x 1): the current depth 
%          - X Y Z (vector n x 1): the unit vectors of the viewing direction of the point (unit sphere).
%          - mask_valid_pixels (matrix sqrt(n) x sqrt(n)): the overlapped pixels for computing the rotation 
%          - step_theta,step_phi,minrow: warping parameters
%          - T_initial: pose in SE(3) (with the estimated value of the rotation)          
%  Output: 
%          - T the pose initialization (rotation + translation) 
%%
function T = init_translation(D_ref,D_cur,sensor_config,mask_valid_pixels,T_initial,sensor_param)

% parameters to set
% angle for which surfaces are being considered overlapped
angle_overlap = 10;
min_depth = 0.5;
max_depth = 15;

T = T_initial;
[h,w] = size(D_ref);
display = 0;

% potential warping positions
pos_warp = 1:numel(mask_valid_pixels);

%% apply T in the reference depth
P3D = depth_p3d(D_ref,sensor_config.unit,T);
tmp = nan(size(D_ref));

[pixel_map,D] = p3D_pixel(P3D,sensor_param);

% see if pixels are valid
pixel_map = round(pixel_map);
pos = find(pixel_map(1,:) > 0 & ~isnan(pixel_map(1,:)) & pixel_map(1,:) <= sensor_param.width ...
    & pixel_map(2,:) > 0 & ~isnan(pixel_map(2,:)) & pixel_map(2,:) <= sensor_param.height);

% select only valid pixels
pixmap = (pixel_map(:,pos));
% build lookuptable / hashtable
index = (pixmap(1,:) - 1)*(sensor_param.height) + pixmap(2,:);
tmp(index) = D(pos);
D_refw = tmp;
D_curw = D_cur;

% %% TODO Comment the next three lines -- making test Scaramuzza images
% D_refw = D_ref;
% D_curw = D_cur;
% mask = mask_valid_pixels;

N_refw = -normals_centered(D_refw,sensor_config.unit);
N_curw = -normals_centered(D_curw,sensor_config.unit);

if(display)
    for k = 1 : 3
        ncolorr(:,:,k) = abs(reshape(N_refw(k,:),h,w));
    end
    figure, imshow(ncolorr);
end

% find overlapped regions (after derotation)
angles = reshape(acos(dot(N_refw,N_curw)),h,w); 
pos_warp = find(abs(angles)<=deg2rad(angle_overlap) & mask_valid_pixels > 0 & D_refw>min_depth & D_refw<max_depth & D_curw>min_depth &  D_curw<max_depth);

% compute the translation
t = compute_translation(D_refw,N_refw,D_curw,N_curw,sensor_config,pos_warp);

T = [T(1:3,1:3) t; zeros(1,3) 1];
