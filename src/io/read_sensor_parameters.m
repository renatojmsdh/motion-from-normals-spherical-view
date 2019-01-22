%% Lagadic Team -- Inria Sophia Antipolis
%  Renato Martins 2017
%  Email: renatojmsdh@gmail.com
%
%  Use: read sensor parameters and stores in the structure
%  sensor_parameters
%  Inputs: - filename (string)%                       
%  Outputs: 
%          - structure with parameters
%
%  Note: Function adapted from read_sequence_parameters from mmeilland
%%

function sensor_parameters = read_sensor_parameters(filename)

fid = fopen(filename);
tline = fgetl(fid);

tab{1} = tline;
i=1;
while ischar(tline)
    i=i+1;
    disp(tline)
    tline = fgetl(fid);
    tab{i} = tline;    
end
fclose(fid);

pos = find( tab{1}=='=');
sensor_parameters.width = str2num(tab{1}(pos+1:end));
pos = find( tab{2}=='=');
sensor_parameters.height = str2num(tab{2}(pos+1:end));
pos = find( tab{3}=='=');
sensor_parameters.ROI_width  = str2num(tab{3}(pos+1:end));
pos = find( tab{4}=='=');
sensor_parameters.ROI_height = str2num(tab{4}(pos+1:end));
pos = find( tab{5}=='=');
sensor_parameters.minrow = str2num(tab{5}(pos+1:end));
pos = find( tab{6}=='=');
sensor_parameters.maxrow = str2num(tab{6}(pos+1:end));
pos = find( tab{7}=='=');
sensor_parameters.step_theta = str2num(tab{7}(pos+1:end));
pos = find( tab{8}=='=');
sensor_parameters.step_phi = str2num(tab{8}(pos+1:end));
pos = find( tab{11}=='=');
sensor_parameters.baseline = str2num(tab{11}(pos+1:end));
pos = find( tab{12}=='=');
sensor_parameters.sensor_type = tab{12}(pos+2:end);


% fid = fopen(filename, 'r');
% fprintf(fid, 'WIDTH = %d\n', wFULL); 1
% fprintf(fid, 'HEIGHT = %d\n', hFULL); 2
% fprintf(fid, 'ROI_WIDTH = %d\n', wROI); 3 
% fprintf(fid, 'ROI_HEIGHT = %d\n', hROI); 4 
% fprintf(fid, 'TOP_PIXEL = %d pix\n', minrow); 5 
% fprintf(fid, 'BOTTOM_PIXEL = %d pix\n', maxrow); 6 
% fprintf(fid, 'STEP_THETA = %f rad\n',step_theta); 7 
% fprintf(fid, 'STEP_PHI = %f rad\n',step_phi); 8 
% fprintf(fid, 'TOP = %f rad\n', minrow*step_phi-pi/2); 9 
% fprintf(fid, 'BOTTOM = %f rad\n', maxrow*step_phi-pi/2); 10 
% fprintf(fid, 'BASELINE = %f m\n', norm(Tbt(1:3,4))); 11
% fclose(fid);
