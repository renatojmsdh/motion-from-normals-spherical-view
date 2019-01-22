%% Lagadic Team -- Inria Sophia Antipolis
%  Renato Martins 2017
%  Email: renatojmsdh@gmail.com
%
%  Use: Find the overlapped pixels between two views using the surface normals
%  Inputs: - N_ref,N_cur (matrix 3 x mn): reference and current normals
%          - pos_warp (vector n x 1): valid pixels to warp
%          - mask_reference (matrix m x n): valid matrix
%          - display2 (flag): display flag
%          - number (integer): the frame number (it is equivalent to GLOBAL variable 'indexImage'
%   
%  Outputs: 
%          - validPixels (vector n x 1): pixel indices of overlapped surfaces
%          
%%

function validPixels = findInliersRot_new(N_ref,N_cur,pos_warp,mask_reference,display2,number)

global indexImage
global namef
global flagsInitialization

% discretization precision 5 degrees
n = ceil(360/5);
s = -pi:2*pi/n:pi;

% threshold for chhecking multi-modes
thresmode = 0.8;

% observability flag
rot_obs = 1;

%%residuals 
%in z -- R G B = Z Y X
N_refz = sqrt(N_ref(2,pos_warp).^2+N_ref(3,pos_warp).^2); N_refz(N_refz<0.1) = nan;
N_curz = sqrt(N_cur(2,pos_warp).^2+N_cur(3,pos_warp).^2); N_curz(N_curz<0.1) = nan;

N_projr = zeros(3,size(pos_warp,1));
N_projc = N_projr;

N_projr([2 3],:) = N_ref([2 3],pos_warp)./repmat(N_refz,2,1);
N_projc([2 3],:) = N_cur([2 3],pos_warp)./repmat(N_curz,2,1);

residualszs = cross(N_projr,N_projc); 
residualsza = dot(N_projr,N_projc);  
% avoid rounding errors -- otherwise acos is complex
residualsza(residualsza>1) = 1; residualsza(residualsza<-1) = -1;
residualsz = acos(residualsza).*sign(residualszs(1,:));
%keyboard
if(display2)
    figure, hist(rad2deg(residualsz),rad2deg(s));
    axis([-180 180 0 inf]);
    xlabel('angle Z [deg]');
    ylabel('hist');
    legend('angle projected Z');
    axis([-180 180 0 inf]);
    grid
    %matlab2tikz('./tikzfolder/figure/hisz.tikz', 'height', '\figureheight', 'width', '\figurewidth');
end

Nz = isnan(N_refz.*N_curz); 

% mask_pixels = zeros(size(mask_reference));
% mask_pixels(pos_warp) = deg2rad(residualsz);
% figure, imshow(mask_pixels)
% keyboard
[mz, indz] = findmodes_rob(residualsz,s,thresmode);
%keyboard
Nz(indz{1}>0) = 1;

if(mz>1)
    rot_obs = 0;
    if(display2)
        for i = 1:mz
            N = zeros(size(N_refz));
            mask_pixels = zeros(size(mask_reference));
            N(indz{i}>0) = 1; mask_pixels(pos_warp) = N;
            figure, imshow(mask_pixels);
            title(['valid pixels X for mode ' num2str(i)]);
            imwrite(mask_pixels,[namef 'valid_pixelsx_mode_' num2str(i) '_' num2str(indexImage) '.png']);
            %saveas(gcf,[namef 'valid_pixelsx_mode_' num2str(i) '_' num2str(indexImage) '.png'])
            close(gcf);
        end
        figure, hist(rad2deg(residualsz),rad2deg(s));
        %title('angle in X');
        xlabel('angle X [deg]');
        ylabel('hist');
        grid;
        saveas(gcf,[namef 'normal_histx_' num2str(indexImage) '.png'])
        matlab2tikz([namef 'normal_histx_' num2str(indexImage) '.tikz'],'height', '\figureheight', 'width', '\figurewidth')
        close(gcf);
    end
end

if(display2)
    zz = zeros(size(mask_reference));
    zz(pos_warp) = Nz;
    figure, imshow(zz);
    title('inliers in Z');
    %imwrite(zz,['./tikzfolder/videoICRA/inZ' sprintf('%04d',number) '.png']);
end

%p = find(count == max(count(1:end)));
%pos_warp = find(residuals<=bin(p) & residuals>=bin(p-1) | residuals<=bin(1));

N_refy = sqrt(N_ref(1,pos_warp).^2+N_ref(3,pos_warp).^2); N_refy(N_refy<0.1) = nan;
N_cury = sqrt(N_cur(1,pos_warp).^2+N_cur(3,pos_warp).^2); N_cury(N_cury<0.1) = nan;

N_projr = zeros(3,size(pos_warp,1));
N_projc = N_projr;

N_projr([1 3],:) = N_ref([1 3],pos_warp)./repmat(N_refy,2,1);
N_projc([1 3],:) = N_cur([1 3],pos_warp)./repmat(N_cury,2,1);

% residualsy = cross(N_projr,N_projc); 
% residualsy = asin(residualsy(2,:));
residualsys = cross(N_projr,N_projc); 
residualsya = (dot(N_projr,N_projc));
residualsya(residualsya>1) = 1; residualsya(residualsya<-1) = -1;
residualsy = acos(residualsya).*sign(residualsys(2,:));
if(display2)
    figure, hist(rad2deg(residualsy),rad2deg(s));
    axis([0 180 0 inf]);
    xlabel('angle Y [deg]');
    ylabel('hist');
    legend('angle projected Y');
    grid;
    %matlab2tikz('./tikzfolder/figure/histy.tikz', 'height', '\figureheight', 'width', '\figurewidth');
end

%keyboard
Ny = isnan(N_refy.*N_cury); 
[my, indy] = findmodes_rob(residualsy,s,thresmode);
Ny(indy{1}>0) = 1;

if(my>1)
    rot_obs = 0;
    if(display2)
        for i = 1:my
            N = zeros(size(N_refy));
            mask_pixels = zeros(size(mask_reference));
            N(indy{i}>0) = 1; mask_pixels(pos_warp) = N;
            figure, imshow(mask_pixels);
            title(['valid pixels Y for mode ' num2str(i)]);
            %saveas(gcf,[namef 'valid_pixelsy_mode_' num2str(i) '_' num2str(indexImage) '.png'])
            imwrite(mask_pixels,[namef 'valid_pixelsy_mode_' num2str(i) '_' num2str(indexImage) '.png']);
            close(gcf);
        end
        figure, hist(rad2deg(residualsy),rad2deg(s));
        %title('angle in Y');
        xlabel('angle Y [deg]');
        ylabel('hist');
        grid;
        saveas(gcf,[namef 'normal_histy_' num2str(indexImage) '.png'])
        %matlab2tikz([namef 'normal_histy_' num2str(indexImage) '.tikz'],'height', '\figureheight', 'width', '\figurewidth')
        close(gcf);
    end
    
    %keyboard
end

if(display2)
    zz = zeros(size(mask_reference));
    zz(pos_warp) = Ny;
    figure, imshow(zz);
    xlabel('angle Y [deg]');
    ylabel('hist');
    grid;
    title('inliers in Y');
    %imwrite(zz,['./tikzfolder/videoICRA/inY' sprintf('%04d',number) '.png']);
end

N_refx = sqrt(N_ref(1,pos_warp).^2+N_ref(2,pos_warp).^2); N_refx(N_refx<0.1) = nan;
N_curx = sqrt(N_cur(1,pos_warp).^2+N_cur(2,pos_warp).^2); N_curx(N_curx<0.1) = nan;

N_projr = zeros(3,size(pos_warp,1));
N_projc = N_projr;

N_projr([1 2],:) = N_ref([1 2],pos_warp)./repmat(N_refx,2,1);
N_projc([1 2],:) = N_cur([1 2],pos_warp)./repmat(N_curx,2,1);

% residualsx = cross(N_projr,N_projc); 
% residualsx = asin(residualsx(3,:));
residualsxs = cross(N_projr,N_projc); 
residualsxa = (dot(N_projr,N_projc));
residualsxa(residualsxa>1) = 1; residualsxa(residualsxa<-1) = -1;
residualsx = acos(residualsxa).*sign(residualsxs(3,:));
if(display2)
    figure, hist(rad2deg(residualsx),rad2deg(s));
    axis([0 180 0 inf]);
    xlabel('angle X [deg]');
    ylabel('hist');
    legend('angle projected X');
    grid;
    %matlab2tikz('./tikzfolder/figure/histx.tikz', 'height', '\figureheight', 'width', '\figurewidth');
    %nanmedian(residualsx)
    %nanmedian(residualsy)
    %nanmedian(residualsz)
end
%keyboard
Nx = isnan(N_refx.*N_curx); 
[mx,indx] = findmodes_rob(residualsx,s,thresmode);
Nx(indx{1}>0) = 1;

if(display2)
figure;
v = {'angle X [deg]', 'angle Y [deg]', 'angle Z [deg]'};
subplot(1,3,1), hist(rad2deg(residualsz),rad2deg(s)); grid;
    ylabel('hist');
    xlabel(v{1});
    subplot(1,3,2), hist(rad2deg(residualsy),rad2deg(s)); grid;
    ylabel('hist');
    xlabel(v{2});
subplot(1,3,3), hist(rad2deg(residualsx),rad2deg(s)); grid;
    ylabel('hist');
    xlabel(v{3});
    
end
 
   % keyboard


if(mx>1)
    rot_obs = 0;
    if(display2)
        % multi-modal dist
        for i = 1:mx
            N = zeros(size(N_refx));
            mask_pixels = zeros(size(mask_reference));
            N(indx{i}>0) = 1; mask_pixels(pos_warp) = N;
            figure, imshow(mask_pixels);
            title(['valid pixels for mode ' num2str(i)]);
            imwrite(mask_pixels,[namef 'valid_pixelsz_mode_' num2str(i) '_' num2str(indexImage) '.png']);
            %saveas(gcf,[namef 'valid_pixelsz_mode_' num2str(i) '_' num2str(indexImage) '.png'])
            close(gcf);
        end
        figure, hist(rad2deg(residualsx),rad2deg(s));
        %title('angle in Z');
        xlabel('angle Z [deg]');
        ylabel('hist');
        grid;
        saveas(gcf,[namef 'normal_histz_' num2str(indexImage) '.png'])
        matlab2tikz([namef 'normal_histz_' num2str(indexImage) '.tikz'],'height', '\figureheight', 'width', '\figurewidth')
        close(gcf);
        %keyboard
    end
    
end

if(display2)
    zz = zeros(size(mask_reference));
    zz(pos_warp) = Nx;
    figure, imshow(zz);
    title('inliers in X');
    %imwrite(zz,['./tikzfolder/videoICRA/inX' sprintf('%04d',number) '.png']);
end

Nn = Nx.*Ny.*Nz;

%valid = find(Nn > 0);
validPixels = zeros(size(mask_reference));
validPixels(pos_warp) = Nn;
%keyboard
if(display2)    
    figure, imshow(validPixels);
    %imwrite(validPixels,['./tikzfolder/videoICRA/goodPixels' sprintf('%04d',number) '.png']);
    %imwrite(validPixels,'./tikzfolder/figure/GoodPixels.png');
end

% TODO -- comment this line -- for generating figures
%rot_obs = 0;

if(~rot_obs)
    flagsInitialization(1) = 1;
    
    if(display2)
        
        [h,w] = size(mask_reference);
        ncolorr = zeros(h,w,3);
        for k = 1 : 3
            ncolorr(:,:,k) = abs(reshape(N_ref(k,:),h,w));
        end
        figure, imshow(ncolorr);
        imwrite(ncolorr,[namef 'normal_ref_' num2str(indexImage) '.png']);
        %saveas(gcf,[namef 'normal_ref_' num2str(indexImage) '.png'])
        close(gcf);
        for k = 1 : 3
            ncolorr(:,:,k) = abs(reshape(N_cur(k,:),h,w));
        end
        figure, imshow(ncolorr);
        imwrite(ncolorr,[namef 'normal_cur_' num2str(indexImage) '.png']);
        %saveas(gcf,[namef 'normal_cur_' num2str(indexImage) '.png'])
        close(gcf);
    end    
    
end


% zz = zeros(size(mask_reference));
% K>> zz(pos_warp(indyy)) = 1;  
% K>> figure, imshow(zz)
% K>> data=residualsy; indyy = find(data<=0.873 & data>=0.803);  
% K>> zz = zeros(size(mask_reference));                        
% K>> zz(pos_warp(indyy)) = 1;                                 
% K>> figure, imshow(zz)                                       
% K>> K>> K>> K>> K>> K>> K>> K>> K>> K>> K>> K>> K>> K>> K>> K>> K>> K>> K>> K>> K>> K>> K>> K>> K>> K>> K>> K>> K>> K>> ncolor = zeros(h,w,3);    
% K>>     for k = 1 : 3
%         ncolor(:,:,k) = abs(reshape(N_cur(k,:),h,w));
%     end
% K>>     figure, imshow(ncolor);
% K>> for k = 1 : 3
%         ncolor(:,:,k) = abs(reshape(N_ref(k,:),h,w));                
% end
% K>>     figure, imshow(ncolor);                          
% K>> data=residualsy; indyy = find(data<=0.873 & data>=0.803);
