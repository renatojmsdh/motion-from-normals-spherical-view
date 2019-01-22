%% Lagadic Team -- Inria Sophia Antipolis 
%  Renato Martins 2017 
%  Email: renatojmsdh@gmail.com
%
%  Use: this is an example for computing the pose initialization
%  from normals using wide FOV sensors as in the IROS 2017 paper:
%  An Efficient Rotation and Translation Decoupled Initialization from Large Field of View Depth Images
%  R Martins, E Fernandez-Moral, P Rives 
%  IEEE/RSJ International Conference on Intelligent Robots and Systems, IROS'17    
%  
%%

clear all; close all; clc;

% Add functions to the matlab PATH
addpath(genpath('src/'))

simulation = 1;
if(simulation)
    % Path of the images in simulation
    image_path = 'data/simulation/';
    imre = 'depth1165.raw';
    imcu = 'depth1180.raw';
else
    % Path of real indoor images
    image_path = 'data/real/';
end

% Read config of the sequence and calibration sensor
sensor_param = read_sensor_parameters([image_path 'config']);

% Multi-resolution images: of k+1 levels
k = 4;

% Compute unit vectors -- depending on the sensor model specified in the
% 'config' file
[US,sensor_param_mr] = compute_unit_model(sensor_param,k);

% read depth images
D_ref = read_depth_image([image_path imre],sensor_param.sensor_type);
D_cur = read_depth_image([image_path imcu],sensor_param.sensor_type);

% find valid pixels
% change here to avoid the use of some regions of the image
mask_pixels = ones(size(D_ref));

% multi-resolution
[D_ref_mr,D_cur_mr,mask_pixels_mr] = multi_resolution_images(D_ref,'depth',D_cur,'depth',mask_pixels,'logic',k);

% flags to control the function state: [observability rotation = 0; 
%                                       observability translation = 0;
%                                       conditioning of the linear system]

global flagsInitialization
flagsInitialization = [0; 0; 0];


Nr = -normals_centered(D_ref_mr{k},US);
Nc = -normals_centered(D_cur_mr{k},US);

% initial pose guess
T_initial = eye(4);

% compute rotation initialization
disp('time for estimating normals and the rotation.');
tic;
[angle, valid_pixels, per_inliers] = init_rotation_normals(D_ref_mr{k},D_cur_mr{k},US,mask_pixels_mr{k},mask_pixels_mr{k},T_initial);
% rad2deg(angle)
toc

T = T_initial*(SE3([zeros(3,1);(angle)]));

%% compute translation initialization
param = [sensor_param_mr.width sensor_param_mr.minrow];
disp('time for estimating normals and the translation');

tic;
sensor_config.type = 'spherical';
sensor_config.unit = US;
sensor_config.param = [sensor_param_mr.width sensor_param_mr.minrow sensor_param_mr.maxrow];
% reference to current
T = init_translation(D_ref_mr{k},D_cur_mr{k},sensor_config,mask_pixels_mr{k},T,sensor_param_mr);
% current to reference
T = inv(T);
% find rotation angles
r = vrrotmat2vec(T(1:3,1:3));
angle = rad2deg(r(1:3)*r(1,4))';
%T(1:3,4)
toc

% display results and observability
if(flagsInitialization(1))
    disp('Could not estimate the rotation.'); 
elseif(flagsInitialization(2)) 
    disp('Rotation estimated:' ); 
    T
    disp('But could not estimate the translation.');
    disp('Translation conditionning:');
    flagsInitialization(3)
else
    disp('Estimated pose: w and t ');
    angle
    T(1:3,4)
    
    % file with ground truth poses
    T_true = load_trajectory([image_path 'trajectory.traj']);
    if(simulation)
        Trc = inv(reshape(T_true(1166,:),4,4))*(reshape(T_true(1181,:),4,4));
    else
        Trc = inv(reshape(T_true(1166,:),4,4))*(reshape(T_true(1181,:),4,4));
    end
    %rot = (norm(skewcoords(skewlog(Trc(1:3,1:3)))));
    r = vrrotmat2vec(Trc(1:3,1:3));
    disp('Ground truth pose: w and t ');
    % rotation ground truth
    rad2deg(r(1:3)*r(1,4))'
    % translation ground truth
    Trc(1:3,4)
end



