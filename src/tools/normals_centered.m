%% Lagadic Team -- Inria Sophia Antipolis
%  Renato Martins 2017
%  Email: renatojmsdh@gmail.com
%
%  Use: centered normal vector computation (uses four neighbours to compute
%  the normal). The derivate in this case is accurate to the second order
%  (one order more accurate than using the central - right - bottom
%  Inputs: - D (matrix h x w): depth image
%          - US (cell of matrices): the unit sphere coordinates such as X = US{1}, Y = US{2}, ...                   
%  Outputs: 
%          - N (matrix 3 x hw): the normals pointing to the origin
%%
function N = normals_centered(D,US,h,w)

if(nargin == 2)
    % build point cloud
    [h,w] = size(D);
    P = [reshape(US(:,:,1).*D,1,h*w); reshape(US(:,:,2).*D,1,h*w); reshape(US(:,:,3).*D,1,h*w)];
else
    P = D;    
end

% avoid borders
[xmap, ymap] = meshgrid(2:w-1,2:h-1);

% find coordinates in memory. Matlab stores matrices with column wise order
% central pixel
idx_c = ymap+(xmap-1)*h;
% left
idx_l = ymap+(xmap-2)*h;
% right
idx_r = ymap+(xmap)*h;
% top
idx_t = ymap-1+(xmap-1)*h;
% bottom 
idx_b = ymap+1+(xmap-1)*h;

Va = zeros(3,h*w);
Vb = zeros(3,h*w);

% compute 1st order numerical derivates -- tangent lines (plane)
Va(:,idx_c) = single(P(:,idx_r)-P(:,idx_l))/2;
Vb(:,idx_c) = single(P(:,idx_b)-P(:,idx_t))/2;

% find orthogonal vector
N = -cross(Va,Vb);

N_norm = normvector(N,1);
N = N./repmat(N_norm,3,1);

% take out not valid pixels or rounding errors (e.g. coming from the derivates) 
pos = or(N_norm<1e-6,isnan(N_norm));
N(:,pos) = 0;

%% NOTES: 
% Output meshgrid (map of matrice indices): [h,w] = size(M) [xmap, ymap] =
% meshgrid(1:w,1:h) == M(ymap,xmap)
% ymap (column constant)
% xmap (row constant) access A(ymap,xmap)

