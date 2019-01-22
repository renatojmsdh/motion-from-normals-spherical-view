%% Lagadic Team -- Inria Sophia Antipolis 
%  Renato Martins 2017 
%  Email: renatojmsdh@gmail.com
%
%  Build unit model from sensor spec
%
%  Inputs: - sensor parameters
%          - level resolution 
%                  
%  Output: 
%          - US (matrix MxNx3) of unit sensor model
%
%%

function [US,sensor_param_mr] = compute_unit_model(sensor_param,level)

w = (sensor_param.width)/(2^(level-1));
h = sensor_param.height/(2^(level-1));

% if spherical model
[x,y,z] = gensphere(w,h);

% minrow is an odd number
minrow = ceil((sensor_param.minrow)/(2^(level-1)));
% maxrow is even
maxrow = floor(sensor_param.maxrow/(2^(level-1)));

%d = sensor_param.ROI_height/(2^(level-1));
%minrow = (h-d)/2;
X_ROI = x(minrow:maxrow,:);
Y_ROI = y(minrow:maxrow,:);
Z_ROI = z(minrow:maxrow,:);

US = zeros(maxrow-minrow+1,w,3);
US(:,:,1) = X_ROI;
US(:,:,2) = Y_ROI;
US(:,:,3) = Z_ROI;

% parameters new resolution
sensor_param_mr.width = w;
sensor_param_mr.height = maxrow-minrow+1;
sensor_param_mr.minrow = minrow;
sensor_param_mr.maxrow = maxrow;

%keyboard
