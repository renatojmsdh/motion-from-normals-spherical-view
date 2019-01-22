%% Lagadic Team -- Inria Sophia Antipolis
%  Author: Renato Martins 2017
%  Email:  renatojmsdh@gmail.com
%
%  Use: creates point cloud from depth image and unit vector.
%  Inputs: - depth image
%          - unit vector
%          - optional arguments: T and pos_warp
%          
%  Output: 
%          - the 3D point cloud
%%


function P3D = depth_p3d(D,unit,T,pos_warp)

if(nargin == 2)
    T = eye(4);
    pos_warp = 1:numel(D);
elseif(nargin == 3)
    pos_warp = 1:numel(D);
end

[h,w] = size(D);
P3D_ref = [reshape(unit(:,:,1).*D,1,h*w); reshape(unit(:,:,2).*D,1,h*w); reshape(unit(:,:,3).*D,1,h*w)];

P3D = nan(3,h*w);
% rigid transform in 3D
P3D(:,pos_warp) = T(1:3,:)*[P3D_ref(:,pos_warp); ones(1,length(pos_warp))];