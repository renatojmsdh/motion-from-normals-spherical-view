%% Lagadic Team -- Inria Sophia Antipolis
%  Renato Martins 2017
%  Email: renatojmsdh@gmail.com
%
%  Use: use adapted C++ mex version for Jacobians of (mn x 3)
% 
%  Inputs: - J (vector 3 x n): jacobian to sort
%          - method (string): sorting method
%  Output: 
%          - index (vector n x 1): ordered list of pixels
%%

function index = compute_saliency_geo(J,method)

 if (nargin < 2)
     method = 'SVD_sort';    
 end
 
 N = size(J,1);
 
switch method   
        
    case 'J_sort' 
        index = mex_getBestNPoints_initialization(J,N);        
    
    otherwise
        disp('Not valid option of pixel ordering');      
        
end
