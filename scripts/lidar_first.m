clear all;
clc
addpath(genpath("D:\Master's thesis\LiDAR Data"))
addpath(genpath("D:\Master's thesis\Video data"))
% analyse entire pcap data for pre processing!!
veloReader = velodyneFileReader('2023-06-28_114541.pcap','VLP16');
time_from_start = 0;
frame_start = 55;
%ptCloudObj = readFrame(veloReader,veloReader.StartTime + seconds(time_from_start)); 
ptCloudObj = readFrame(veloReader,frame_start);
frame_no = find(veloReader.Timestamps-veloReader.CurrentTime>=0,1);
frame_start = frame_no;
% define counter
i=1;

% define region of interest
zlimits = ptCloudObj.ZLimits;
poi = [-13 2 -11 11 zlimits];

% initialise pc player: with roi
player0 = pcplayer(poi(1:2),poi(3:4),poi(5:6));
view(player0,ptCloudObj.Location,ptCloudObj.Intensity);
% for showing detected pedestrian
player1 = pcplayer(poi(1:2),poi(3:4),poi(5:6));

% time stamping
timestamp = veloReader.Timestamps - veloReader.Timestamps(1);
% datetime(1687945542.19, 'ConvertFrom', 'epochtime', 'Format', 'dd-MMM-uuuu HH:mm:ss.SSS')
gps_times = datetime(2023,06,28,11,45,42,190,"Format","dd-MMM-uuuu HH:mm:ss.SSS") + timestamp; % based on name

%to find inclination of lidar in xz plane - input organised pt cloud.
angle_deg = inclination_ground(ptCloudObj);

% parameters for transformation
rotationAngles = [0 angle_deg 0]; translation = [0 0 0];
tform = rigidtform3d(rotationAngles,translation);

% initialise pedestrian location
person_last = [-0.98 0.4 -0.24]; 
person_curr = person_last;
while(hasFrame(veloReader) && veloReader.CurrentTime <= veloReader.EndTime - seconds(2.5))
    ptCloudObj = readFrame(veloReader);
    ptCloudObj = lidar_preprocessing(ptCloudObj,poi);
    ptCloudObj = pctransform(ptCloudObj,tform);
    view(player0,ptCloudObj.Location,ptCloudObj.Intensity);
    % segmentations & bounding box
    [index,numClusters] = pcsegdist(ptCloudObj,0.5,"ParallelNeighborSearch",true);%,"NumClusterPoints",25);
    clusters = unique(index);

    % to find centroid of every cluster
    centroids = centroid_of_clusters(ptCloudObj,index);

    % to track moving object: pedestrian in this case
    centroid_diff = centroids - person_last;
    [distance(i),person] = min(vecnorm(centroid_diff,2,2));
    
    person_curr = centroids(person,:);
    idx = find(index==(person));
    person_last = person_curr;
    detection = select(ptCloudObj,idx);
    X(i) = person_curr(1);
    Y(i) = person_curr(2);
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
    dfo(i) = norm(person_curr);
    %printing
    fprintf("distance = %.2f angle = %.2f\n", dfo(i),degs(i));
    view(player1,detection.Location,detection.Intensity);
    view(player0,ptCloudObj.Location,ptCloudObj.Intensity);
    pause(0.1);
    
    frame_no = frame_no + 1;

    % error check - person moving unreasonably fast
    if(distance(i)>1)
        error("segment lost!")
    end
    i=i+1;
end
% time stamp vs distance matrix
frame_end = frame_no-1;
Lidar_times = gps_times(frame_start:frame_end);
times_string = string(datestr(Lidar_times, 'yyyy-mm-dd HH:MM:SS.FFF'));
time_dist(:,1) = times_string;
time_dist(:,2) = string(X);
time_dist(:,3) = string(Y);
time_dist(:,4) = string(dfo);
time_dist(:,5) = string(degs);


%% to extract velocity and heading angle from trajectory
% Initialize variables for velocity and heading angle
velocity = zeros(size(X));
heading_angle = zeros(size(X));

% Calculate velocity and heading angle for each point
for i = 2:length(X)
    % Calculate Euclidean distance between consecutive points
    dist = norm([X(i) - X(i-1), Y(i) - Y(i-1)]);
    
    % Calculate time difference between consecutive frames (assuming constant frame rate)
    time_diff = seconds(timestamp(i) - timestamp(i-1)); % Modify this value based on your frame rate
    
    % Calculate velocity by dividing distance by time
    velocity(i) = dist / time_diff;
    
    % Calculate heading angle using atan2 function
    heading_angle(i) = atan2d(Y(i) - Y(i-1), X(i) - X(i-1));
end








% % write a variable to json file
% json_str = jsonencode(time_dist);
% 
% fid = fopen('mydata.json', 'w');
% 
% % Write the JSON string to the file
% fprintf(fid, '%s', json_str);
% 
% % Close the file
% fclose(fid);