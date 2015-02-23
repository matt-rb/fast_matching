function [ ranked_list ] = choose_candidate( bin_query_vectors, voting_tables, sub_table_bit_size )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
    voting_table_count = size(voting_tables,1);
    query_samples_count = size(bin_query_vectors,1);
    
    candidate_list = cell(query_samples_count, voting_table_count);
    
    
    for vote_tbl_idx=1:voting_table_count
        start_idx = ((vote_tbl_idx-1)*sub_table_bit_size)+1;
        end_idx = start_idx+sub_table_bit_size-1;
        temp_vector= bin_query_vectors(:,start_idx:end_idx);
        values = unique(bi2de(temp_vector,'left-msb'));
        for val=1:size(values,1)
            indexs = find(bi2de(temp_vector,'left-msb')==values(val));
            candidate_list(indexs,vote_tbl_idx) = {voting_tables{vote_tbl_idx}{values(val)+1}};
        end
        
    end
    
     ranked_list  = ranking_list(candidate_list );
    
end

function [ ranked_lists ] = ranking_list(candidate_list)
    
    
    query_count = size(candidate_list,1);
    vote_tables_counts = size(candidate_list,2);
    ranked_lists = cell(query_count,1);
    for query_idx=1:query_count
        ranked_list = [candidate_list{query_idx,1},ones(size(candidate_list{query_idx,1},1),1)];
        for vote_no=2:vote_tables_counts
            tt = ismember(ranked_list(:,1),candidate_list{query_idx,vote_no});
            ranked_list(find(tt),2) = ranked_list(find(tt),2) + 1;
            tt = ismember(candidate_list{query_idx,vote_no},ranked_list(:,1));
            tt = find(~tt);
            ranked_list = [ranked_list ; [candidate_list{query_idx,vote_no}(tt) , ones(size(tt,1),1)]];
        end
        [~,I]=sort(ranked_list(:,2),'descend');
        ranked_list=ranked_list(I,:);
        ranked_lists{query_idx} = ranked_list;
    end

end

