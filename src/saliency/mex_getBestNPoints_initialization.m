%% Lagadic Team -- Inria Sophia Antipolis
%  Renato Martins 2017
%  Email: renatojmsdh@gmail.com
%
%  Use: compute saliency for an arbitrary number of DOF (extends the
%  implementation of [Meilland 2012] beyhond 6 DOFs
% 
%  Inputs: - J (vector 3 x n): jacobian to sort
%          - pos_warp (vector n x 1): indices of valid jacobians
%          - param (vector 2 x 1): height and width original sphere
%  Output: 
%          - mask with the valid pixels positions 
%%

function [index, deg] = mex_getBestNPoints_initialization(J,N)

if N > size(J,1)
    disp('N was automaticaly resized ');
    N = size(J,1);
end

% number of degrees of freedom
DOF = size(J,2);

for i = 1 : DOF
    [Jsort(:,i) ind(:,i)] = sort(abs(J(:,i)),'descend');           
end

ind = reshape(ind',1,N*DOF)-1;
[index, deg] = mex_saliency_geometry(ind',N,DOF);
index = index + 1;
