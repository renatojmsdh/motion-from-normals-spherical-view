%% Lagadic Team -- Inria Sophia Antipolis
%  Renato Martins 2017
%  Email: renatojmsdh@gmail.com
%
%  Use: compute norm 2 of vector/matrix along dimension d
%  Inputs: - (vector) x
%          - (int) d = 1 (by column), d = 2 (by row)
%  Output: norm 2 of the vector matrix
%
%%
function normv = normvector(x,d)

normv = sqrt(sum(x.^2,d));

end
