function [ hash_table ] = make_hash_table( bin_vect, orig_vecotr, kps)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
    hash_table = cell(bi2de(ones(1,size(bin_vect,2)),'left-msb')+1,2);
    fprintf(1,'Claculate Hash Table (size %d) current: ',size(bin_vect,1));
    for i=1:size(bin_vect,1)
        reverseStr = repmat(sprintf('\b'), 1, length(num2str(i-1)));
        fprintf(1,strcat(reverseStr,'%d'),i);
        hash_table(bi2de(bin_vect(i,:),'left-msb')+1,1) = {[cell2mat(hash_table(bi2de(bin_vect(i,:),'left-msb')+1,1)) ; orig_vecotr(i,:)]};
        hash_table(bi2de(bin_vect(i,:),'left-msb')+1,2) = {[cell2mat(hash_table(bi2de(bin_vect(i,:),'left-msb')+1,2)) ; kps(i,:)]};
    end
end

