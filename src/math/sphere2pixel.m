%% Lagadic Team -- Inria Sophia Antipolis
%  Renato Martins 2017
%  Email: renatojmsdh@gmail.com
%
%  Use: Convert from spherical coordinates (theta,phi) to pixel coordinates (u,v)
%  Inputs: - Ps (matrix mn x 2): spherical coordinates
%          - param (2 x 1): sensor projection parameters
%   
%  Outputs: 
%          - pixel_map (vector n x 1): pixel coordinates
%          - D (matrix m x n): depth image
%     
%%

function pixel_map = sphere2pixel(Ps,param)

if(size(Ps,1) == 2)
    Ps = [Ps; ones(1,size(Ps,2))];
end

% from spherical coordinates to pixel coordinates
n = param(1)/2; minrow = param(2);
K = [n/pi 0 n ; 0 n/pi n/2 - (minrow-1)];
% (theta,phi)
pixel_map = K*Ps;

% matrix K put pixels starting from (0,0) but in Matlab indices begin at (1 1) -- so
% need to add 1s
pixel_map = pixel_map + ones(size(pixel_map));
