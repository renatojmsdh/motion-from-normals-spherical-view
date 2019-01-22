%% Lagadic Team -- Inria Sophia Antipolis
%  Renato Martins 2017
%  Email: renatojmsdh@gmail.com
%
%  Use: compute rotation angles using overlapped and projected normals
% 
%  Inputs: - N_ref,N_cur (matrix 3 x mn): reference and current normals
%          - projAxis (string): projection axis ('x', 'y', 'z')
%          - delta (0 < double < 1): minimum norm value of the projection
%          - pos_warp (vector n x 1): pixel warping positions
%   
%  Output: 
%          - angle (vector 3 x 1): instaneous rotation angles
%	   - axisSign (vector 3 x 1): signal of rotation
%%

function [angle, axisSign] = projectedAngle(N_ref,N_cur,projAxis,delta,pos_warp)

% axis defined as in the sensor frame
% R G B = Z Y X

if(projAxis == 'x')
    proj = [2,3];
elseif(projAxis == 'y')
    % positive rotation is from z to x
    proj = [1,3];
elseif(projAxis == 'z')
    proj = [1,2];
end    

N_refx = sqrt(N_ref(proj(1),pos_warp).^2+N_ref(proj(2),pos_warp).^2); N_refx(N_refx<delta) = nan;
N_curx = sqrt(N_cur(proj(1),pos_warp).^2+N_cur(proj(2),pos_warp).^2); N_curx(N_curx<delta) = nan;

N_projr = zeros(3,size(pos_warp,1));
N_projc = N_projr;

N_projr(proj,:) = N_ref(proj,pos_warp)./repmat(N_refx,2,1);
N_projc(proj,:) = N_cur(proj,pos_warp)./repmat(N_curx,2,1);

%angle = acos(dot(N_ref(proj,pos_warp),N_cur(proj,pos_warp))./(N_refx.*N_curx))*180/pi; 
% avoid rounding errors -- acos is complex outside [-1,1]
a = dot(N_projr,N_projc); a(a>1) = 1; a(a<-1) = -1;
angle = nanmedian(acos(a)); 

% the transform takes the reference to current
axisSign = cross(N_projr,N_projc);

if(projAxis == 'x')
    axisSign = axisSign(1,:)';
elseif(projAxis == 'y') 
    
    axisSign = axisSign(2,:)';
elseif(projAxis == 'z')
    axisSign = axisSign(3,:)';
end  

axisSign = nanmedian(sign(axisSign));
if(axisSign == 0)
    axisSign = 1;
end

if(isnan(axisSign) || isnan(angle))
    angle = 0; axisSign = 0;
end

