%% Lagadic Team -- Inria Sophia Antipolis
%  Renato Martins 2017
%  Email: renatojmsdh@gmail.com
%
%  Use: read depth image coming from different sensors.
%       The sensor type is indicated in the last line of read_parameters function 
%  Inputs: - filename (string)
%          - type_sensor (string)             
%  Outputs: 
%          - The depth image in meters
%%

function D = read_depth_image(filename,type_sensor)

% if outdoor rig sensor
if(strcmp(type_sensor,'outdoor'))
    file = fopen(filename,'r');
    h = fread(file,1,'uint16');
    w = fread(file,1,'uint16');
    D = reshape(fread(file,h*w,'float32'),h,w);
    fclose(file);

% if indoor rig sensor
elseif(strcmp(type_sensor,'indoor'))
    D = imread(filename);
    D = double(D);
    D = D/1000;
    %disp('Depth max');
    %max(max(D))

% if sponza atrium images
elseif(strcmp(type_sensor,'simulation'))
    file = fopen(filename,'r');
    h = fread(file,1,'uint16');
    w = fread(file,1,'uint16');
    % stored in row-wise order
    D = reshape(fread(file,h*w,'float32'),w,h)';
    fclose(file);
end
