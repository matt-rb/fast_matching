clear all;
close all;
startup;
ref_img_root='data/ref.jpg';
des_img_root='data/des.jpg';
%load('kps.mat');
pca_size = 21;
sub_table_size = 3;
n_iter = 5;

I_ref = imread(ref_img_root);
[kps_ref,desc_ref]=sift(rgb2gray(I_ref));
% kps_ref = kps(1:2,8001:813679);
% desc_ref= kps(4:131,8001:813679);

I_des = imread(des_img_root);
[kps_des,desc_des]=sift(rgb2gray(I_des));
% kps_des = kps(1:2,1:8000);
% desc_des= kps(4:131,1:8000);

tic ;
%matches=siftmatch( desc_ref, desc_des ) ;
fprintf('SIFT-Matching in %.3f s\n', toc) ;



%figure(1) ; clf ;
%plotmatches(rgb2gray(I_ref),rgb2gray(I_des),kps_ref(1:2,:),kps_des(1:2,:),matches) ;
%drawnow ;
%fprintf('No. Ref Kps %d \nNo. Test Kps %d \nNo. Matches %d \n ', size(desc_ref,2), size(desc_des,2), size(matches,2) ) ;

%v = sqrt(sum((desc_des(:,matches(2,:)) - desc_ref(:,matches(1,:))) .^ 2));
%avg_err = sum(v)/size(v,2);
%fprintf('-- SIFT-Matching AVG-distance %.3f \n', avg_err) ;


[ bin_vect,itq_rot_mat,pca_mapping, mean_data ] = train_itq( pca_size, n_iter, desc_ref' );

tic;
fprintf('Make Reference Hash Table...\n') ;
hash_table = make_hash_table( bin_vect, desc_ref', kps_ref');
fprintf('\tDONE\n') ;
fprintf('Reference Hash in %.3f s\n', toc) ;


tic;
fprintf('Make Voting Tables... ') ;
voting_tables = make_subhash_tables( bin_vect, hash_table, sub_table_size );
fprintf('\tDONE\n') ;
fprintf('Voting Tables in %.3f s\n', toc) ;


tic;
fprintf('Make Query Hash Table... ') ;
bin_des = test_itq( desc_des', itq_rot_mat, pca_mapping);

%table_des = make_hash_table( bin_des, desc_des', kps_des');
ranked_list = choose_candidate( bin_des, voting_tables, sub_table_size );
fprintf('\tDONE\n') ;
fprintf('Query Hash in %.3f s\n', toc) ;

no_mtch=0;

tic ;
kps_ref = [];
kps_des_matched =[];
desc_ref = [];
desc_des_matched = [];

fprintf('MultiHash Matching\n') ;

for i=1:size(ranked_list,1)
    hash_idx= ranked_list{i}(1,1);
    if(size(hash_table{hash_idx,1},1)>0)
        desc_ref=[desc_ref , hash_table{hash_idx,1}(1,:)'];
        kps_ref=[kps_ref , hash_table{hash_idx,2}(1,:)'];
        kps_des_matched = [kps_des_matched , kps_des(:,i)];
        desc_des_matched = [desc_des_matched , desc_des(:,i)];
    end
end
                    
fprintf('-- MultiHash Matching in %.3f s\n', toc) ;                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  
fprintf('No. Matches %d \n ', no_mtch ) ;

v = sqrt(sum((desc_des_matched(:,:) - desc_ref(:,:)) .^ 2));
avg_err = sum(v)/size(v,2);
fprintf('Hash-Matching AVG-distance %.3f \n', avg_err) ;

matches = [1:size(kps_ref,2); 1:size(kps_ref,2)]; 
figure(2) ; clf ;
plotmatches(rgb2gray(I_ref),rgb2gray(I_des),kps_ref(1:2,:),kps_des_matched(1:2,:),matches) ;
drawnow ;                                                                                                                                                                                                                                                                                                                                                                                                                                                plotmatches(rgb2gray(I_ref),rgb2gray(I_des),kps_ref(1:2,:),kps_des(1:2,:),matches) ;