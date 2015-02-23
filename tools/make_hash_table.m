function [ hash_table ] = make_hash_table( bin_vect, orig_vecotr, kps)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
    binary_size= size(bin_vect,2);
    hash_size = bi2de(ones(1,binary_size),'left-msb')+1;
    hash_table = cell(hash_size,3);
    fprintf(1,'Claculate Hash Table (size %d) current: ',hash_size);
    for i=1:hash_size
        reverseStr = repmat(sprintf('\b'), 1, length(num2str(i-1)));
        fprintf(1,strcat(reverseStr,'%d'),i);
        idx_binaries = find (bi2de(bin_vect(:,:),'left-msb')==(i-1));
        hash_table(i,1) = {orig_vecotr(idx_binaries,:)};
        hash_table(i,2) = {kps(idx_binaries,:)};
        hash_table(i,3) = {de2bi(i-1,binary_size,'left-msb')};
    end
end

