clc
clear
% to read Velodyne .pcap point cloud file.
% create an velodyneFileReader object 
%path_folder= "D:\Master's thesis\plot_pcap.m";
addpath(genpath("D:\Master's thesis\LiDAR Data"))
addpath(genpath("D:\Master's thesis\Video data"))
veloReader = velodyneFileReader('2023-06-28_114541.pcap','VLP16');
% to ensure we have frames 
%veloReader.CurrentTime = veloReader.StartTime +  seconds(20);
% frame_no = find(veloReader.Timestamps-veloReader.CurrentTime>=0,1);
frame_start = 55; % reference from VeloView
% delta time between frames
% to create pointCloud object
ptCloudObj = readFrame(veloReader,frame_start);
% start a pcplayer
xlimits = ptCloudObj.XLimits;
ylimits = ptCloudObj.YLimits;
zlimits = ptCloudObj.ZLimits;
% to show original scan
player0 = pcplayer(xlimits,ylimits,zlimits);
view(player0,ptCloudObj.Location,ptCloudObj.Intensity);
%player = pcplayer(xlimits,ylimits,zlimits);
poi = [-13 2 -11 11 zlimits];
% to show scan in region of interest
player1 = pcplayer(poi(1:2),poi(3:4),poi(5:6));
person_last = [-0.98 0.4 -0.24];  
person_curr = person_last;

%to find inclination of lidar in xz plane - input organised pt cloud.
angle_deg = inclination_ground(ptCloudObj);
% parameters for transformation
rotationAngles = [0 angle_deg 0]; translation = [0 0 0];
tform = rigidtform3d(rotationAngles,translation);
i=1;
% to display all the frames with pause of 0.1s
while(hasFrame(veloReader) && veloReader.CurrentTime <= veloReader.EndTime - seconds(2))
ptCloudObj = readFrame(veloReader);
pc_new = lidar_preprocessing(ptCloudObj,poi);
pc_new = pctransform(pc_new,tform);
% segmentations & bounding box
    [index,numClusters] = pcsegdist(pc_new,0.5,"ParallelNeighborSearch",true);%,"NumClusterPoints",25);
    clusters = unique(index);

    % to find centroid of every cluster
    centroids = centroid_of_clusters(pc_new,index);

    % to track moving object: pedestrian in this case
    centroid_diff = centroids - person_last;
    [distance(i),person] = min(vecnorm(centroid_diff,2,2));

    person_curr = centroids(person,:);
    idx = find(index==(person));
    person_last = person_curr;
    detection = select(pc_new,idx);
    X(i) = person_curr(1);
    Y(i) = person_curr(2);
    % degs(i) = atand(Y(i)/X(i));
    % finding degs - algo
    if(X(i) < 0 && Y(i)<0)
        degs(i) = atand(Y(i)/X(i));
    elseif(X(i) < 0 && Y(i)>0)
        degs(i) = atand(Y(i)/X(i));
    elseif(X(i) > 0 && Y(i)<0)
        degs(i) = 180 + atand(Y(i)/X(i));
    else
        degs(i) = -180 + atand(Y(i)/X(i));
    end
    %printing
    dfo(i) = norm(person_curr);
    fprintf("distance = %.2f angle = %.2f\n", dfo(i),degs(i));

view(player0,ptCloudObj.Location,ptCloudObj.Intensity);
view(player1,pc_new.Location,pc_new.Intensity);
% view(player2,select(pc_rot,idx));
pause(0.1);
i=i+1;
end


