
clear all;
close all;
startup;
ref_img_root='data/ref.jpg';
des_img_root='data/des.jpg';
kmeans_size = 8;
load('kps.mat');

% I_ref = imread(ref_img_root);
% [kps_ref,desc_ref]=sift(rgb2gray(I_ref));
kps_ref = kps(1:2,8001:813679);
desc_ref= kps(4:131,8001:813679);


% I_des = imread(des_img_root);
% [kps_des,desc_des]=sift(rgb2gray(I_des));
kps_des = kps(1:2,1:8000);
desc_des= kps(4:131,1:8000);

% tic ;
% matches=siftmatch( desc_ref, desc_des ) ;
% fprintf('SIFT-Matching in %.3f s\n', toc) ;
% v = sqrt(sum((desc_des(:,matches(2,:)) - desc_ref(:,matches(1,:))) .^ 2));
% avg_err = sum(v)/size(v,2);
% fprintf('-- SIFT-Matching AVG-distance %.3f \n', avg_err) ;
% fprintf('No. Ref Kps %d \nNo. Test Kps %d \nNo. Matches %d \n ', size(desc_ref,2), size(desc_des,2), size(matches,2) ) ;


tic;
[lables, centroid]=k_means(desc_ref',kmeans_size);
fprintf('k_means in %.3f s\n', toc) ;

guery_lable= zeros(size(desc_des,2),1);

for pt_idx=1:size(desc_des,2)
   [min_val, min_index] = min(sqrt(sum((repmat(desc_des(:,pt_idx),1,kmeans_size) - centroid') .^ 2)));
   guery_lable(pt_idx)=min_index;
end

tic ;
kps_ref_mtch = [];
kps_des_mtch =[];
desc_ref_mtch = [];
desc_des_mtch = [];
no_mtch=0;
for kmean_idx=1:kmeans_size
    matches=siftmatch( desc_ref(:,lables==kmean_idx), desc_des(:,guery_lable==kmean_idx) ) ;
    if size(matches,2)>0
    no_mtch = size(matches,2) + no_mtch;
    temp_kps_ref = kps_ref(:,lables==kmean_idx);
    temp_kps_des = kps_des(:,guery_lable==kmean_idx);
    temp_desc_ref = desc_ref(:,lables==kmean_idx);
    temp_desc_des = desc_des(:,guery_lable==kmean_idx);
    kps_ref_mtch = [kps_ref_mtch , temp_kps_ref(:,matches(1,:))];
    kps_des_mtch = [kps_des_mtch , temp_kps_des(:,matches(2,:))];
    desc_ref_mtch = [desc_ref_mtch , temp_desc_ref(:,matches(1,:))];
    desc_des_mtch = [desc_des_mtch , temp_desc_des(:,matches(2,:))];
    end
end

fprintf('-- Kmeans-Matching with %d Cluster in %.3f s\n',kmeans_size, toc) ;                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  
fprintf('No. Matches %d \n ', no_mtch ) ;

v = sqrt(sum((desc_ref_mtch(:,:) - desc_des_mtch(:,:)) .^ 2));
avg_err = sum(v)/size(v,2);
fprintf('Kmeans-Matching AVG-distance %.3f \n', avg_err) ;

% matches = [1:size(kps_ref_mtch,2); 1:size(kps_des_mtch,2)]; 
% figure(2) ; clf ;
% plotmatches(rgb2gray(I_ref),rgb2gray(I_des),kps_ref_mtch(1:2,:),kps_des_mtch(1:2,:),matches) ;
% drawnow ;             


