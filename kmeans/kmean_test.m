
%---- Collect Data -------
train_data=kps(4:131,1:100000);
lables=kmeans(train_data',4);

%----- PCA ----------------
temp_features = train_data';
[temp_features, mean_data] = normalize_features( temp_features );

fprintf('Computing Cov PCA...\n');
Cov=temp_features'*temp_features;
fprintf('Computing Mapping PCA...\n');
[pca_mapping,~]=eigs(Cov,2);
mappeddata = temp_features * pca_mapping;

%------ Visualize 2D --------
spread(mappeddata',lables);
     
%IDX=kmeans(mappeddata,3);