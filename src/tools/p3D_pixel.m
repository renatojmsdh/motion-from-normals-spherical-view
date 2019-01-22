%% Lagadic Team -- Inria Sophia Antipolis
%  Renato Martins 2017
%  Email: renatojmsdh@gmail.com
%
%  Use: pixel from 3D projection
%  Inputs: - P3D (matrix m x n x 3): the 3D points
%          - D_cur (matrix m x n): the current depth 
%          - US (vector m x n x 3): the unit vectors of the viewing direction of the point (unit sphere)
%          - mask_reference,mask_saliency (m x n): reference and saliency masks
%          - T_intitial (4 x 4): rigid transform between the frames -- Default identity matrix T = eye(4)
%          - sensor_config (structure): sensor projection parameters
%   
%  Outputs: 
%          - pixel_map (vector n x 1): pixel coordinates
%          - D (matrix m x n): depth image
%     
%%

function [pixel_map,D] = p3D_pixel(P3D,sensor_config)

% spheric warping model
%if(strcmp(sensor_config.type,'spherical'))
        
    D = normvector(P3D,1);
    % from Cartesian to spherical coordinates
    Ps = [atan2(P3D(1,:),P3D(3,:)); atan2(P3D(2,:),normvector(P3D([1,3],:),1)); ones(1,size(P3D,2))];       
    param = [sensor_config.width sensor_config.minrow];
    % convert from spherical coordinates (theta, phi) to pixel coordinates
    pixel_map = sphere2pixel(Ps,param);
    
%else
%    keyboard;
end
