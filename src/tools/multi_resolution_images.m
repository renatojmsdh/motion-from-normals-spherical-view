%% Lagadic Team -- Inria Sophia Antipolis 
%  Renato Martins 2017 
%  Email: renatojmsdh@gmail.com
%
%  Perform multi-resolution for different image types:
%  - numeric (img) (use classic Gaussian kernel
%  - mask or binary (logical)
%  - depth (custom sub-sampling)
%  Inputs: - Couples (data, type data) for sub-sampling
%          - Last parameter is the number of levels 
%                  
%  Output: 
%          - A cell array containing a cell array of the multi-resolution
%           images
%
%%

function varargout = multi_resolution_images(varargin)

% number of images
ninputs = (max(nargin,2)-1)/2;

% number of layers
l = varargin{nargin};

for k = 1:ninputs,
    
    varargout{k}{1} = varargin{2*(k-1)+1};
    
    % if normal image -- classic impyramid
    if(strcmp(varargin(2*(k-1)+2),'img'))       
        
        for i = 2:l+1,
            varargout{k}{i} = impyramid(varargout{k}{i-1},'reduce');
        end
    end
    
    % if mask or logic image
    if(strcmp(varargin(2*(k-1)+2),'logic')) 
        
        for i = 2:l+1,
            varargout{k}{i} = imresize(varargout{k}{i-1},0.5,'nearest');
        end
    end
    
    % if depth image -- do not consider values with zero 
    % custom sub-sampling with nan
    if(strcmp(varargin(2*(k-1)+2),'depth'))
        
        min_depth = 0.1;
        % put nan in non valid pixels -- pixels with zero value        
        varargout{k}{1}(varargout{k}{1}<min_depth) = nan;
        
        % Custom Gaussian pyramid for the depth
        a = 0.375;
        w1 = [1/4-a/2 1/4 a 1/4 1/4-a/2];
        gauss_filter = w1'*w1;
        
        for i = 2:l+1,
            depth_sampled = nanconv(varargout{k}{i-1},gauss_filter, 'nonanout');             
            varargout{k}{i} = imresize(depth_sampled,0.5,'nearest');
        end
    end
    
end

end
