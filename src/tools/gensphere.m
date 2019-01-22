function [Xs Ys Zs step_theta step_phi] = gensphere(width,height) 

[xmap ymap] = meshgrid(0:width-1,0:height-1);

step_theta = 2*pi/width;
step_phi = pi/height;

theta = xmap*step_theta-pi;  %+step_theta/2 
phi = ymap*step_phi - pi/2; %+step_phi/2

Xs = sin(theta).*cos(phi);
Ys = sin(phi);
Zs = cos(theta).*cos(phi);
