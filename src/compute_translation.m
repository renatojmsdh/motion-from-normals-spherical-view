%% Lagadic Team -- Inria Sophia Antipolis
%  Renato Martins 2017
%  Email: renatojmsdh@gmail.com
%
%  Use: find the translation from the overlapped pixels.
%  Inputs: - D_ref (vector n x 1): the reference depth (after de-rotation)
%          - N_ref (vector 3 x n): the reference normals after derotation
%          - D_cur (vector n x 1): the current depth 
%          - N_cur (vector 3 x n): the current normals 
%          - X Y Z (vector n x 1): the unit vectors of the viewing direction of the point (unit sphere).
%  Output: 
%          - t (3 x 1): the translation 
%%
function t = compute_translation(D_reff,N_reff,D_curf,N_curf,sensor_config,pos_warp)

global indexImage
global namef
global flagsInitialization

N_refn = N_reff(:,pos_warp);
N_curn = N_curf(:,pos_warp);
D_refn = D_reff(pos_warp);
D_curn = D_curf(pos_warp);

% max angle normal - view direction
angle2 = 70;

% max condit
max_cond = 20;

% translation observability
observ_trans = 1;
X = sensor_config.unit(:,:,1);
Y = sensor_config.unit(:,:,2);
Z = sensor_config.unit(:,:,3);
npn = [X(pos_warp)'; Y(pos_warp)'; Z(pos_warp)'];
n1 = dot(N_curn,npn)';

%% using saliency
% consider the points that have a viewing angle of max 70 deg
pos = abs(n1)>cos(deg2rad(angle2));

pos_warp2 = pos_warp(pos);
saliency_points = saliency_geometry_sphere(N_curn(:,pos)',pos_warp2,size(D_refn));
pos2 = find(saliency_points>0);

proj = [1,2,3];
cdx = cond(N_curn(:,pos2));
if(cdx > max_cond)
    % take out the dimension we could not estimate
    % perform svd ([u,s,v] =svd(A);   

    % rank reduction using gaussian-jordan ellimination with partial pivoting
    [r,proj] = rref(N_curn(:,pos2)*N_curn(:,pos2)',0.05*size(N_curn(:,pos2),2));    
    
    if(numel(proj)<2)        
       if(proj==1)
           proj=[1 2];
       elseif(proj==2)
           proj = [1 2];
       else
           proj = [2 3];
       end       
    end
    
    N_cur = zeros(3,size(pos2,1));
    N_ref = N_cur;
    
    N_cur(proj,:) = N_curn(proj,pos2);
    N_ref(proj,:) = N_refn(proj,pos2);
    np = zeros(size(N_cur));
    np(proj,:) = npn(proj,pos2);
    observ_trans = 0;
    flagsInitialization(2) = 1;
else
    N_ref = N_refn(:,pos2);
    N_cur = N_curn(:,pos2);
    np = npn(:,pos2);    
end

D_ref = D_refn(pos2);
D_cur = D_curn(pos2);

% normal_vector_distribution(N_cur,240);
n1 = dot(N_cur,np)';

n2 = zeros(size(n1));
% axis
cr = cross(N_ref,N_cur);
axisr = cr./repmat(normvector(cr,1),3,1);

% angle
rot = acos(dot(N_ref,N_cur));

for i = 1:size(N_ref,2),
    if(abs(rad2deg(rot(i)))>0.5)        
        % small rotation approximation
        R = eye(3) + ppv(axisr(:,i)*rot(i));
    else
        R = eye(3);
    end
    n2(i) = N_cur(:,i)'*R*np(:,i);
end


d = D_cur.*n1 - D_ref.*n2;
A = N_cur(proj,:);

t = zeros(3,1);

% solve the system
if(length(d)>5)
t(proj) = robustfit(A',d,'huber',[],'off');
end
t(isnan(t)) = 0;
