function [ itq_bin_mat,itq_rot_mat,pca_mapping, mean_data ] = train_itq( pca_size, n_iter, temp_features ,mute)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
    
    if ~exist('mute','var')
        mute=false;
    end
    if ~mute
        fprintf('Normalize Data...\n');
    end
    [temp_features, mean_data] = normalize_features( temp_features );

    %----- PCA ---------
    if ~mute
        fprintf('Computing Cov PCA...\n');
    end
    Cov=temp_features'*temp_features;
    if ~mute
        fprintf('Computing Mapping PCA...\n');
    end
    [pca_mapping,~]=eigs(Cov,pca_size);
    mappeddata = temp_features * pca_mapping;
    if ~mute
        fprintf('Computing ITQ...\n');
    end
    [itq_bin_mat,itq_rot_mat] = ITQ(mappeddata, n_iter);
end

