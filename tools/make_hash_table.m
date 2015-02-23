function [ hash_table ] = make_hash_table( bin_vect, orig_vecotr, kps, mute)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
    if ~exist('mute','var')
        mute=false;
    end
    
    hash_size = bi2de(ones(1,size(bin_vect,2)),'left-msb')+1;
    hash_table = cell(hash_size,2);
    if ~mute
        fprintf(1,'Claculate Hash Table (size %d) current: ',hash_size);
    end
    for i=1:hash_size
        if ~mute
            reverseStr = repmat(sprintf('\b'), 1, length(num2str(i-1)));
            fprintf(1,strcat(reverseStr,'%d'),i);
        end;
        idx_binaries = find (bi2de(bin_vect(:,:),'left-msb')==(i-1));
        hash_table(i,1) = {orig_vecotr(idx_binaries,:)};
        hash_table(i,2) = {kps(idx_binaries,:)};
    end
end

