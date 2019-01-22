%% Lagadic Team -- Inria Sophia Antipolis
%  Renato Martins 2017
%  Email: renatojmsdh@gmail.com
%
%  Use: find and extract modes from a distribution.
%  Inputs: - data (vector): the data of the distribution
%          - s (vector) or (int): if 's' is a vector, the distribution is done using bin = s
%            if 's' is a scalar, the distribution is going to be computed with bin = [min(data):max(data)-min(data)/s:max(data) 
%          - threshold (double): to extract all modes smaller than threshold*(main mode) in case of multimodal distribution
%  Outputs: 
%          - number of modes
%          - cell array with the indices of the data that belongs to each mode.
%%

function [nmodes,indmodes] = findmodes_rob(data,s,threshold)

% initially only the max peak is considered

%% attention -- I've observed a difference between the count and the plotted bins using hist
% '[count,bin] = hist(data,s)' is different than the count plotted in the
% 'figure using hist(data,s)'. The behavior becames similar when we use
% only the number of bins 'numel(s)' instead of the bins itself. To check
% later.

% convert edges to center
centerd = s(2)-s(1);

% it is circular the dist
center = s + centerd/2;

[count,bin] = hist(data,center);

% with histc, we can specify the bins edges directly
%[count,bin] = hist(data,s);
%keyboard
% convert back center to edges
edge = bin(2) -bin(1);
bin = bin+edge/2;
%bin = s;

ind = zeros(size(data));
pp = find(count >= max(count));
pp1 = find(count >= threshold*max(count));

% consider near bins as inliers
valid_bins = find(abs(pp1 - pp(1)) < 3);

for i = 1:size(valid_bins,2),
    p = pp1(valid_bins(i));
    if(p >1)
        pos_pp = find(data<=bin(p) & data>=bin(p-1));
    else
        pos_pp = find(data<=bin(p));
    end
    
    ind(pos_pp) = 1;    
end

indmodes{1} = ind;

% check if the distribution is multi-modal 
if(numel(valid_bins)==numel(pp1))
    nmodes = 1;
    return
else
    
    % do for other modes
    remaining_modes = ones(size(pp1));
    % exclude already used bins
    remaining_modes(valid_bins) = 0;
    % find the second max mode -- not used
    pp = find(count(pp1(remaining_modes>0)) >= max(count(pp1(remaining_modes>0))));
    valid_bins = find(abs(pp1(remaining_modes>0) - pp1(pp(1))) < 3);
    %pp = find(count >= threshold*max(count) & count < max(count));
    %% rmartins
    % should do recursive for more than two bins    
    nmodes = sum(remaining_modes) - numel(valid_bins) + 2;
    
    if(~isempty(valid_bins))
        %pp = find(count >= threshold*max(count));
        for i = 1:size(valid_bins,2),
            indx = zeros(size(data));
            p = pp1(valid_bins(i));
            if(p >1)
                pos_pp = find(data<=bin(p) & data>=bin(p-1));
            else
                pos_pp = find(data<=bin(p));
            end
            
            indx(pos_pp) = 1;
            indmodes{i+1} = indx;
        end
    end
end
