%% Lagadic Team -- Inria Sophia Antipolis
%  Renato Martins 2017
%  Email: renatojmsdh@gmail.com
%
%  Use: visualization of the normal directions (in the sphere)
%  Input:  - N (vector 3 x n): normal vactors to plot
%         
%%

function normal_vector_distribution(N,param)
global indexImage
global namef

pos = sum(N.^2,1) > 0;

figure, scatter3(N(1,pos), N(2,pos), N(3,pos), '.');
axis square; 
xlabel('X', 'FontSize', 20);
ylabel('Y', 'FontSize', 20);
zlabel('Z', 'FontSize', 20);

x0 = zeros(3,1);
hold on, plot3(x0(1)+[0, 1, nan, 0, 0, nan, 0, 0],x0(2)+[0, 0, nan, 0, 1, nan, 0, 0], x0(3)+[0, 0, nan, 0, 0, nan, 0, 1],'k','Linewidth',5);
text([x0(1)+1, x0(1), x0(1)], [x0(2), x0(2)+1, x0(2)], [x0(3), x0(3), x0(3)+1], ['+X';'+Y';'+Z'],'Color','r');

% 
% %% inverse near the poles (X,Z near to zero) -- arbitrary theta. Fix for phi
[theta, phi, r] = cart2sph(N(1,pos),N(2,pos),N(3,pos));

n = param(1);
%C = hist3([ymap' xmap'],[n n]);
C = hist3([phi' theta'],{-pi/2:pi/n:pi/2 -pi:pi/n:pi});
number = size(N(:,pos),2)/n;

C(C>number) = number;

Ddisp = (C-min(C(:)))/(max(C(:))-min(C(:)))*255+1;
lut = lines(255);
Ddisp_color = zeros([size(Ddisp),3]);
for k = 1 : 3
    Ddisp_color(:,:,k) = reshape(lut(uint8(Ddisp),k),size(Ddisp));
end
