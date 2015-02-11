
%---- Collect Data -------
train_data=kps(4:131,1:100000);
tic;
[lables, centroid]=k_means(train_data',3);
fprintf('k_means in %.3f s\n', toc) ;

tic;
[lables]=kmeans(train_data',3);
fprintf('kmeans in %.3f s\n', toc) ;

[S,H] = silhouette(train_data', lables);
silA(3)=mean(S);

%Plot the results
clf %clear the figure window
hold on
plot(1:4, silA,'ok-','MarkerFaceColor','k') %2 groups
%plot(1:4, silB,'or-','MarkerFaceColor','r') %1 group
set(gca,'XTick',1:4)
xlabel('k')
ylabel('mean silhouette value')
hold off


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