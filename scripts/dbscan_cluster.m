%%dbscan clustering
function [idx,index,clusters] = dbscan_cluster(pc_new,eps,min_points)
xyzpoints = pc_new.Location;
index = dbscan(xyzpoints,eps,min_points);
clusters = unique(index);
% figure
% hold on
% for i = 1:length(clusters)
%     % Extract points belonging to a cluster
%     clusterPoints = xyzpoints(index == clusters(i), :);
% 
%     % Plot points in the cluster
%     scatter3(clusterPoints(:,1), clusterPoints(:,2), clusterPoints(:,3), 'filled');
% end
% title('DBSCAN Clustering of Point Cloud Data')
% xlabel('X')
% ylabel('Y')
% zlabel('Z')
idx = find(index==1);
end