function [ min_idx ] = find_min_distance_idx( desc_single, desc_collection )
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
    %Y=sqrt(sum((repmat(desc_single(:,:), 1, size(desc_collection,2)) - desc_collection(:,:)) .^ 2));
    %min_idx = find(Y == max(Y(:)));
    min_idx = 0;
    mt=siftmatch( desc_single, desc_collection );
    if size(mt)>0
        min_idx = mt(2);
    end
end

