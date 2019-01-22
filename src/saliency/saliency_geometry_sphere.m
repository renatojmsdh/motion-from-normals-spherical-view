%% Lagadic Team -- Inria Sophia Antipolis
%  Renato Martins 2017
%  Email: renatojmsdh@gmail.com
%
%  Use: compute saliency for an arbitrary number of DOF (extends the
%  implementation of [Meilland 2012] beyhond 6 DOFs
% 
%  Inputs: - Jp (vector 3 x n): jacobian to sort
%          - pos_warp (vector n x 1): indices of valid jacobians
%          - param (vector 2 x 1): height and width original sphere
%  Output: 
%          - mask with the valid pixels positions 
%%

function mask_saliency = saliency_geometry_sphere(Jp,pos_warp,param)

h = param(1); w = param(2);

index = compute_saliency_geo(Jp,'J_sort');

RATIO = 0.8;
npixels = round(RATIO*size(Jp,1));

mask_saliency = zeros(size(Jp,1),1);
mask_saliency(index(1:npixels))=1;

end
