%% to compute centroid of clusters
function centroids = centroid_of_clusters(pc_rot,index)
cluster_id = unique(index);
no_of_cluster = length(cluster_id);
for i=1:no_of_cluster
    clusterPoints = select(pc_rot, find(index == i));
    if(clusterPoints.Count~=1)
        centroids(i,:) = mean(clusterPoints.Location);
    else
        centroids(i,:) = clusterPoints.Location;
    end
end
%disp(centroids);