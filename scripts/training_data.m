% to form training data
% for every camera frame in which person is detected, find corresponding
% distance, x, y and angle from LIDAR.
%load('2023-05-17_163112.mat');
X = X'; Y=Y';degs=degs';dfo=dfo';
% camera is on first
first_index = find(Lidar_times(1)<=time_person(:,1),1);

%% interpolation at camera time
for i=first_index:length(time_person)
    camera_time = time_person(i);
    camera_frame = frame_person(find(camera_time==time_person(:,1),1));
    lidar_a_time = find(camera_time<Lidar_times,1);
    lidar_b_time = lidar_a_time -1;
    Xcoordinate = interp1(Lidar_times(lidar_b_time:lidar_a_time),X(lidar_b_time:lidar_a_time),camera_time);
    Ycoordinate = interp1(Lidar_times(lidar_b_time:lidar_a_time),Y(lidar_b_time:lidar_a_time),camera_time);
    dist_object = interp1(Lidar_times(lidar_b_time:lidar_a_time),dfo(lidar_b_time:lidar_a_time),camera_time);
    angle_object = interp1(Lidar_times(lidar_b_time:lidar_a_time),degs(lidar_b_time:lidar_a_time),camera_time);
    train_data(i-first_index+1,:) = [camera_frame,Xcoordinate,Ycoordinate,dist_object,angle_object];
    cam_time(i-first_index+1,1) = camera_time;
end

%% to add bbcoordinates into training data
for i=1:length(train_data)
    frame_no = train_data(i,1);
    train_data(i,6:9) = bbcoordinate(find(frame_person==frame_no),:);
end

% to filter out repeating bbox coordinates to avoid bias/overfitting!!
[~,ind_bb] = unique(train_data(:,8:9),"rows"); 
ind_bb = sort(ind_bb);

%% keep iterating rounding 
% rounding of distance and angle to avoid overfitting
train_data(:,10)=round(train_data(:,4),2);
train_data(:,11) = round(train_data(:,5),1);
[~,ind_d] = unique(train_data(:,10:11),"rows"); 
ind_d = sort(ind_d);
train_index = intersect(ind_d,ind_bb);
% to plot training data
% x vs y 
plot(train_data(train_index,2),train_data(train_index,3),'o')
figure
% angle vs distance
plot(train_data(train_index,5),train_data(train_index,4),'o')
% to do the translation of origin of pixels
center = [365,0];
% create train dataset [distance angle bottom_mid_bb_x bottom_mid_bb_y]
clear train_data1
train_data1(:,1) = train_data(train_index,10); % distance
train_data1(:,2) = train_data(train_index,11); % angle
train_data1(:,3) = mean([train_data(train_index,6),train_data(train_index,8)],2) - center(1);
train_data1(:,3) = round(train_data1(:,3)); % lower mid x
train_data1(:,4) = train_data(train_index,9) - center(2); % lower y
train_data1(:,5) = train_data(train_index,9) - train_data(train_index,7); % height
train_data1(:,6) = train_data(train_index,8) - train_data(train_index,6); % width
% make sure - unique data
[~,index] = unique(train_data1(:,3:4),"rows");
train_data1 = train_data1(index,:);
% plot training data
% x vs y 
figure
plot(train_data1(:,2),train_data1(:,1),'o')

%% form training data based on [x y] of lidar pc
train_data_xy(:,1) = train_data(:,2); % X
train_data_xy(:,2) = train_data(:,3); % Y
train_data_xy(:,3) = train_data(:,10); % distance
train_data_xy(:,4) = train_data(:,11); % angle
train_data_xy(:,5) = mean([train_data(:,6),train_data(:,8)],2) - center(1);
train_data_xy(:,5) = round(train_data_xy(:,5)); % lower mid x
train_data_xy(:,6) = train_data(:,9) - center(2); % lower y
train_data_xy(:,7) = train_data(:,9) - train_data(:,7); % height
train_data_xy(:,8) = train_data(:,8) - train_data(:,6); % width
train_data_xy(:,9) = train_data(:,7) - center(2); % top y




