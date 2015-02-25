
%% Initialization

clear all;
close all;
startup;
ref_img_root='data/ref.jpg';
des_img_root='data/des.jpg';
kmeans_size = 32;
pca_size = 6;
n_iter = 5;
%load('kps.mat');

%% ------------------------ Train Phase -----------------------------------





%% Train - Collect train/test data 

I_ref = imread(ref_img_root);
[kps_ref,desc_ref]=sift(rgb2gray(I_ref));
% kps_ref = kps(1:2,8001:813679);
% desc_ref= kps(4:131,8001:813679);

I_des = imread(des_img_root);
[kps_des,desc_des]=sift(rgb2gray(I_des));
% kps_des = kps(1:2,1:8000);
% desc_des= kps(4:131,1:8000);



%% Normal-Sift

% tic ;
% matches=siftmatch( desc_ref, desc_des ) ;
% fprintf('SIFT-Matching in %.3f s\n', toc) ;
% v = sqrt(sum((desc_des(:,matches(2,:)) - desc_ref(:,matches(1,:))) .^ 2));
% avg_err = sum(v)/size(v,2);
% fprintf('-- SIFT-Matching AVG-distance %.3f \n', avg_err) ;
% fprintf('No. Ref Kps %d \nNo. Test Kps %d \nNo. Matches %d \n ', size(desc_ref,2), size(desc_des,2), size(matches,2) ) ;


%% Train - Clustering reference samples with kmeans

tic;
[lables_ref, centroid]=k_means(desc_ref',kmeans_size);
fprintf('k_means in %.3f s\n', toc) ;



%% Train - Build up hash tables for each cluster

itq_rot_mat= cell(kmeans_size,1);
pca_mapping= cell(kmeans_size,1);
bin_vect = cell(kmeans_size,1);

% train ITQ and compute hash binary vectors
for lbl_idx=1:kmeans_size
    [ bin_vect_temp,itq_rot_mat_temp,pca_mapping_temp, ~ ] = ...
        train_itq( pca_size, n_iter, desc_ref(:,lables_ref==lbl_idx)', true);
    itq_rot_mat(lbl_idx)={itq_rot_mat_temp};
    pca_mapping(lbl_idx)={pca_mapping_temp};
    bin_vect(lbl_idx)={bin_vect_temp}; 
end
clear itq_rot_mat_temp  pca_mapping_temp mean_data lbl_idx;

% Build up hash tables
hash_tables = cell(kmeans_size,1);
tic;
fprintf('Make Reference Hash Table... ') ;
for lbl_idx=1:kmeans_size
    hash_table_temp = make_hash_table( cell2mat(bin_vect(lbl_idx)),...
                                       desc_ref(:,lables_ref==lbl_idx)',...
                                       kps_ref(:,lables_ref==lbl_idx)', true);
    hash_tables(lbl_idx) = {hash_table_temp};
end
clear hash_table_temp  lbl_idx ;

fprintf('\tDONE\n') ;
fprintf('Reference Hash in %.3f s\n', toc) ;



%% ------------------------ Test Phase -----------------------------------





%% Test - Labling test samples

guery_lable= zeros(size(desc_des,2),1);

for pt_idx=1:size(desc_des,2)
   [min_val, min_index] = min(sqrt(sum((repmat(desc_des(:,pt_idx),1,kmeans_size) - centroid') .^ 2)));
   guery_lable(pt_idx)=min_index;
end


%% Test - test-ITQ and build up query hash-tables

query_tables = cell(kmeans_size,1);

%tic;
%fprintf('Make Query Hash Table... ') ;
for lbl_idx=1:kmeans_size
    bin_des = test_itq( desc_des(:,guery_lable==lbl_idx)', cell2mat(itq_rot_mat(lbl_idx)), cell2mat(pca_mapping(lbl_idx)));
    query_tables(lbl_idx) = {make_hash_table( bin_des, desc_des(:,guery_lable==lbl_idx)', kps_des(:,guery_lable==lbl_idx)', true)};
end
%fprintf('\tDONE\n') ;
%fprintf('Query Hash in %.3f s\n', toc) ;




tic ;
kps_ref_mtch = [];
kps_des_mtch =[];
desc_ref_mtch = [];
desc_des_mtch = [];
no_mtch=0;

for kmean_idx=1:kmeans_size
    table_des = query_tables{kmean_idx};
    hash_table = hash_tables {kmean_idx};
    for i=1:size(hash_table,1)
    %fprintf('Hash Level %d \n', i) ;
        if size(cell2mat(table_des(i,1)),1) >0 && size(cell2mat(hash_table(i,1)),1) >0
            matches=siftmatch( cell2mat(hash_table(i,1))', cell2mat(table_des(i,1))' ) ;
            no_mtch = size(matches,2) + no_mtch;
            temp_kps_ref = cell2mat(hash_table(i,2))';
            temp_kps_des = cell2mat(table_des(i,2))';
            temp_desc_ref = cell2mat(hash_table(i,1))';
            temp_desc_des = cell2mat(table_des(i,1))';
            kps_ref_mtch = [kps_ref_mtch , temp_kps_ref(:,matches(1,:))];
            kps_des_mtch = [kps_des_mtch , temp_kps_des(:,matches(2,:))];
            desc_ref_mtch = [desc_ref_mtch , temp_desc_ref(:,matches(1,:))];
            desc_des_mtch = [desc_des_mtch , temp_desc_des(:,matches(2,:))];
        end
    end
end

fprintf('-- Kmeans-hash Matching with %d Cluster and hash %d-bit in %.3f s\n',kmeans_size,pca_size, toc) ;                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  
%fprintf('No. Matches %d \n', no_mtch ) ;

v = sqrt(sum((desc_ref_mtch(:,:) - desc_des_mtch(:,:)) .^ 2));
avg_err = sum(v)/size(v,2);
fprintf('Kmeans-hash Matching AVG-distance %.3f \n', avg_err) ;

% matches = [1:size(kps_ref_mtch,2); 1:size(kps_des_mtch,2)]; 
% figure(2) ; clf ;
% plotmatches(rgb2gray(I_ref),rgb2gray(I_des),kps_ref_mtch(1:2,:),kps_des_mtch(1:2,:),matches) ;
% drawnow ; 

