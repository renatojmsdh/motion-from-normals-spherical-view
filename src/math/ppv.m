function A = ppv(v) ;
% PPV  Antisymmetric matrix for cross product.
%
%   A = ppv(v) returns the antisymmetric matrix A 
%   such that A*w = v x w is the cross product of 
%   the vectors v and w. v must be 3 element vector.
%
%   See also vpp.

if (size(v,1)*size(v,2) ~= 3) 
  disp('the input must be a (3x1) element vector');
  return
end;

A = [ 0 -v(3) v(2);  v(3) 0 -v(1);  -v(2) v(1) 0];

