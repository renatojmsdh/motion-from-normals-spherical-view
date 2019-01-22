%% Lagadic Team -- Inria Sophia Antipolis
%  Renato Martins 2017
%  Email: renatojmsdh@gmail.com
%
%  Use: estimate rotation and overlapped pixels using the surface normals
%  Inputs: - D_ref (matrix m x n): the reference depth 
%          - D_cur (matrix m x n): the current depth 
%          - US (vector m x n x 3): the unit vectors of the viewing direction of the point (unit sphere)
%          - mask_reference,mask_saliency (m x n): reference and saliency masks
%          - T_intitial (4 x 4): rigid transform between the frames -- Default identity matrix T = eye(4)
%          - sensor_param (structure): sensor projection parameters
%   
%  Outputs: 
%          - angle (3 x 1): the rotation in axis form
%          - validPixels (vector n x 1): list of valid pixels
%          - per_inliers (0 <= scalar <= 1): ratio of inliers
%          - N_ref, N_cur (matrix 3 x mn): reference and current surface normals
%%

function  [angle, validPixels, per_inliers, N_ref, N_cur] = init_rotation_normals(D_ref,D_cur,US,mask_reference,mask_saliency,T_initial,sensor_param)

global flagsInitialization

% display flag
display = 0;

% minimun overlapping
min_inliers = 0.001; 

T = T_initial;
[h, w] = size(mask_reference);

% warp reference depth only if the rigid transform is not the identity
% matrix
C = T - eye(4);
C = max(abs(C(:))) < 0.001;
if(~C)
    % apply T in the reference depth
    P3D = depth_p3d(D_ref,US,T);
    tmp = nan(size(D_ref));
    
    %P3D2 = depth_p3d(D2,US,T);
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
    D_ref = tmp;
end

N_ref = -normals_centered(D_ref,US);
N_cur = -normals_centered(D_cur,US);

if(display)
    ncolorc = zeros(h,w,3);
    for k = 1 : 3
        ncolorc(:,:,k) = abs(reshape(N_ref(k,:),h,w));
    end
    figure, imshow(ncolorc);
end

if(display)
    ncolorc = zeros(h,w,3);    
    for k = 1 : 3
        ncolorc(:,:,k) = abs(reshape(N_cur(k,:),h,w));
    end
    figure, imshow(ncolorc);
    %imwrite(ncolor,['./tikzfolder/videoICRA/normalC' sprintf('%04d',number) '.png']);
end

if(display)
    ncolorr = zeros(h,w,3);
    for k = 1 : 3
        ncolorr(:,:,k) = abs(reshape(N_ref(k,:),h,w)).*mask_reference;
    end
    figure, imshow(ncolorr);
    %imwrite(ncolor,['./tikzfolder/videoICRA/normalR' sprintf('%04d',number) '.png']);
    C = imfuse(ncolorr,ncolorc,'falsecolor','Scaling','joint','ColorChannels',[1 2 0]);
    C = imfuse(ncolorr,ncolorc,'blend','Scaling','joint');
    figure, imshow(C,[]);
end

% potential warping positions
normValidRef = sqrt(N_ref(1,:).^2+N_ref(2,:).^2+N_ref(3,:).^2);
normValidCur = sqrt(N_cur(1,:).^2+N_cur(2,:).^2+N_cur(3,:).^2);
pos_warp = find(mask_reference>0 & mask_saliency>0 & reshape(normValidRef,h,w) > 0.1 & reshape(normValidCur,h,w) > 0.1);

% this segmentation considers also the angles
validPixels = findInliersRot_new(N_ref,N_cur,pos_warp,mask_reference,display,1);

%%%%% Use good pixels to find the initial rotation at each axis
per_inliers = sum(validPixels(:))/size(pos_warp,1);

if(per_inliers > min_inliers)
    
    % find overlaped pixels
    pos = find(validPixels>0);
    
    % compute angle and signs for each component
    [angleZ, sz] = projectedAngle(N_ref,N_cur,'z',0.1,pos);
    [angleY, sy] = projectedAngle(N_ref,N_cur,'y',0.1,pos);
    [angleX, sx] = projectedAngle(N_ref,N_cur,'x',0.1,pos);    
    
    % rotation in axis form
    angle = [angleX*sx;angleY*sy;angleZ*sz];    
  
else  
    % if could not estimate the rotation -- set obervability issue flag to 1
    flagsInitialization(1) = 1;
    angle = [0;0;0];
    
end