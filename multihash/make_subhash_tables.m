function [ voting_tables ] = make_subhash_tables( bin_vect, hash_table, sub_table_bit_size )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
    binary_size= size(bin_vect,2);
    sub_hash_size = bi2de(ones(1,sub_table_bit_size),'left-msb')+1;
    subtables_count = binary_size/sub_table_bit_size;
    voting_tables = cell(subtables_count,1);
    
    for sample_idx=1:sub_hash_size
        for tbl_idx=1:subtables_count
            start_idx = ((tbl_idx-1)*sub_table_bit_size)+1;
            end_idx = start_idx+sub_table_bit_size-1;
            tt = cellfun(@(x) bi2de(x(start_idx:end_idx),'left-msb')==sample_idx-1, hash_table(:,3), 'UniformOutput', 0);
            index = find(cell2mat(tt));
            voting_tables{tbl_idx}{sample_idx} = index;       
        end
    end
    

end

