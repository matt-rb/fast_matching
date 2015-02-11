clear all;
close all;
startup;
ref_img_root='data/ref.jpg';
des_img_root='data/des.jpg';
load('kps.mat');
pca_size = 3;
n_iter = 5;

%I_ref = imread(ref_img_root);
%[kps_ref,desc_ref]=sift(rgb2gray(I_ref));
kps_ref = kps(1:2,8001:813679);
desc_ref= kps(4:131,8001:813679);

%I_des = imread(des_img_root);
%[kps_des,desc_des]=sift(rgb2gray(I_des));
kps_des = kps(1:2,1:8000);
desc_des= kps(4:131,1:8000);

tic ;
matches=siftmatch( desc_ref, desc_des ) ;
fprintf('SIFT-Matching in %.3f s\n', toc) ;

%figure(1) ; clf ;
%plotmatches(rgb2gray(I_ref),rgb2gray(I_des),kps_ref(1:2,:),kps_des(1:2,:),matches) ;
%drawnow ;
%fprintf('No. Ref Kps %d \nNo. Test Kps %d \nNo. Matches %d \n ', size(desc_ref,2), size(desc_des,2), size(matches,2) ) ;

[ bin_vect,itq_rot_mat,pca_mapping, mean_data ] = train_itq( pca_size, n_iter, desc_ref' );

fprintf('Make Reference Hash Table... ') ;
hash_table = make_hash_table( bin_vect, desc_ref', kps_ref');
fprintf('DONE\n') ;

fprintf('Make Query Hash Table... ') ;
bin_des = test_itq( desc_des', itq_rot_mat, pca_mapping);


table_des = make_hash_table( bin_des, desc_des', kps_des');
fprintf('DONE\n') ;

no_mtch=0;

tic ;
kps_ref = [];
kps_des =[];

fprintf('Hash-Matching\n') ;
for i=1:size(hash_table,1)
    fprintf('Hash Level %d \n', i) ;
    if size(cell2mat(table_des(i,1)),1) >0 && size(cell2mat(hash_table(i,1)),1) >0
    matches=siftmatch( cell2mat(hash_table(i,1))', cell2mat(table_des(i,1))' ) ;
    no_mtch = size(matches,2) + no_mtch;
    temp_kps_ref = cell2mat(hash_table(i,2))';
    temp_kps_des = cell2mat(table_des(i,2))';
    kps_ref = [kps_ref , temp_kps_ref(:,matches(1,:))];
    kps_des = [kps_des , temp_kps_des(:,matches(2,:))];
    end
end
fprintf('Hash-Matching in %.3f s\n', toc) ;
fprintf('No. Matches %d \n ', no_mtch ) ;
% matches = [1:size(kps_ref,2); 1:size(kps_ref,2)]; 
% figure(2) ; clf ;
% plotmatches(rgb2gray(I_ref),rgb2gray(I_des),kps_ref(1:2,:),kps_des(1:2,:),matches) ;