
kp_file_root='data/keypoints.txt';

%[pt, desc] = textread(kp_file_root, '%3f %128d', 1);
fileID = fopen(kp_file_root,'r');
formatSpec = '%131f';
sizeA = [131 Inf];

kps = fscanf(fileID,formatSpec,sizeA);
fclose(fileID);

save ('kps','kps');