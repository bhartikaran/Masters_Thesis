%% to do pre processing on the milliseconds counter in json file.
% some issue are 1. no labels 2. unconsistent labels.
addpath(genpath("D:\Master's thesis\Video data"))
jsonfile = fileread('20230628T094338_867648049628025_r608870663_x365y250.json');
jsonfile = jsondecode(jsonfile);
time_ms(:,1) = [jsonfile.detection.uptime]';
%% solution for 20230628T094338_867648049628025_r608870663_x365y250 video file.
for i=1:length(time_ms)
    if(time_ms(i,1)>=608872861 && time_ms(i,1)<=609212579)
        time_ms(i,2) = time_ms(i,1);
    else
        time_ms(i,2)=0;
    end
    % if(floor(time_ms(i,1)/100000000)==4)
    %     time_ms(i,2) = time_ms(i,1)-300000000;
    % end
end
%%
time_ms(:,3) = [0;diff(time_ms(:,2))];
zero_indices = find((time_ms(:,3)>60) | (time_ms(:,3)<0));
nonzero_indices = setdiff([1:10199],zero_indices);
nonzero_indices = nonzero_indices';
%%
% Find the indices of non-zero elements
nonzero_indices = find(time_ms(:,2) ~= 0);
% Find the indices of zero elements
zero_indices = find(time_ms(:,2) == 0);
%% interpolation
time_ms(zero_indices,3) = interp1(nonzero_indices,time_ms(nonzero_indices,3),zero_indices,'linear','extrap');
time_ms(:,3) = round(time_ms(:,3)); 
%%
gps_times_camera = datetime(2023,06,28,11,43,38,646,"Format","dd-MMM-uuuu HH:mm:ss.SSS");
timestamp_camera = seconds(time_ms(:,3)/1000);
for i=2:length(time_ms)
    gps_times_camera(i,1) = gps_times_camera(i-1,1) + timestamp_camera(i);
end
%% to find frame no with matching IDs of me
Ids = [20,39,41,43,44,54];
frame_person = []; bbcoordinate = [];
for i=1:length(time_ms)
    try
    detected_ids = [jsonfile.detection(i).objects.obj_id];
    catch Error
        detected_ids = [];
    end
    id = intersect(Ids,detected_ids);
    if(id)
        id=id(1);
        frame_person = [frame_person;i]; 
        posi = find(detected_ids==id,1);
        bbcoordinate = [bbcoordinate; [jsonfile.detection(i).objects(posi).bbox]'];
    end
end
%% from videos frame_person [3854,10023]
ind = find(frame_person<3854 | frame_person>10023);
frame_person(ind) = [];
bbcoordinate(ind,:) = [];
time_person = gps_times_camera(frame_person);
% %% solution for 20230628T095155_867648049628025_r609367459_x365y250 video file.
% for i=1:length(time_ms)
%     if(time_ms(i,1)>=609371296 && time_ms(i,1)<=609514758)
%         time_ms(i,2) = time_ms(i,1);
%     else
%         time_ms(i,2)=0;
%     end
%     % if(floor(time_ms(i,1)/100000000)==4)
%     %     time_ms(i,2) = time_ms(i,1)-300000000;
%     % end
% end
% % Find the indices of non-zero elements
% nonzero_indices = find(time_ms(:,2) ~= 0);
% % Find the indices of zero elements
% zero_indices = find(time_ms(:,2) == 0);
% % interpolation
% time_ms(zero_indices,2) = interp1(nonzero_indices,time_ms(nonzero_indices,2),zero_indices,'linear','extrap');
% time_ms(:,2) = round(time_ms(:,2)); 
% %%
% time_ms(:,3) = time_ms(:,2)-time_ms(1,2);
% timestamp_camera = seconds(time_ms(:,3)/1000);
% gps_times_camera = datetime(2023,06,28,11,51,55,367,"Format","dd-MMM-uuuu HH:mm:ss.SSS") + timestamp_camera;
% %% solution for 20230628T094338_867648049628025_r608870663_x365y250 video file.
% for i=1:length(time_ms)
%     if(time_ms(i,1)>=608872861 && time_ms(i,1)<=609212579)
%         time_ms(i,2) = time_ms(i,1);
%     else
%         time_ms(i,2)=0;
%     end
%     % if(floor(time_ms(i,1)/100000000)==4)
%     %     time_ms(i,2) = time_ms(i,1)-300000000;
%     % end
% end
% % Find the indices of non-zero elements
% nonzero_indices = find(time_ms(:,2) ~= 0);
% % Find the indices of zero elements
% zero_indices = find(time_ms(:,2) == 0);
% % interpolation
% time_ms(zero_indices,2) = interp1(nonzero_indices,time_ms(nonzero_indices,2),zero_indices,'linear','extrap');
% time_ms(:,2) = round(time_ms(:,2)); 
% % some indices a difference of around 2000 observed
% time_ms(:,3) = [0;diff(time_ms(:,1))];
% time_ms(:,4) = [0;diff(time_ms(:,2))];
% zero_indices = find(abs(time_ms(:,4))>100);
% time_ms(:,5) = time_ms(:,2); % duplicate to do data processing
% %%
% for i = 2:length(time_ms)
%     if(abs(time_ms(i,4))>1500 && i~=2870 && time_ms(i,4)>0)
%         time_ms(i,5) = time_ms(i-1,5) + rem(time_ms(i,4),100);
%         time_ms(i,4) = time_ms(i,5) - time_ms(i-1,5); 
%         time_ms(:,4) = [0;diff(time_ms(:,5))];
%     elseif(abs(time_ms(i,4))>1500 && i~=2870 && time_ms(i,4)<0)
%         time_ms(i,5) = time_ms(i-1,5) + time_ms(i,4) + 2000;
%         time_ms(i,4) = time_ms(i,5) - time_ms(i-1,5);
%         time_ms(:,4) = [0;diff(time_ms(:,5))];
%     elseif(abs(time_ms(i,4))>100 && i~=2870)
%         time_ms(i,5) = time_ms(i-1,5) + 33;
%         time_ms(i,4) = time_ms(i,5) - time_ms(i-1,5);
%         time_ms(:,4) = [0;diff(time_ms(:,5))];
%     elseif(time_ms(i,4)<0 && i~=2870)
%         time_ms(i,5) = time_ms(i-1,5) + 33;
%         time_ms(i,4) = time_ms(i,5) - time_ms(i-1,5);
%         time_ms(:,4) = [0;diff(time_ms(:,5))];
%     end
% end
% time_ms(:,3) = time_ms(:,5)-time_ms(1,5);
% timestamp_camera = seconds(time_ms(:,3)/1000);
% gps_times_camera = datetime(2023,06,28,11,43,38,646,"Format","dd-MMM-uuuu HH:mm:ss.SSS") + timestamp_camera;
%% solution for 20230420T145606_867648049628025_r749624_x350y260 video file.
% for i=1:length(time_ms)
%     if(time_ms(i,1)>=751868 && time_ms(i,1)<=837488)
%         time_ms(i,2) = time_ms(i,1);
%     else
%         time_ms(i,2)=0;
%     end
%     % if(floor(time_ms(i,1)/100000000)==4)
%     %     time_ms(i,2) = time_ms(i,1)-300000000;
%     % end
% end
% % Find the indices of non-zero elements
% nonzero_indices = find(time_ms(:,2) ~= 0);
% % Find the indices of zero elements
% zero_indices = find(time_ms(:,2) == 0);
% % interpolation
% time_ms(zero_indices,2) = interp1(nonzero_indices,time_ms(nonzero_indices,2),zero_indices,'linear','extrap');
% time_ms(:,2) = round(time_ms(:,2)); 
% nl_indices = [];
% for i=1:length(time_ms)-1
%     if((time_ms(i+1,2)-time_ms(i,2))>60 || (time_ms(i+1,2)-time_ms(i,2))<5)
%         nl_indices = [nl_indices;i+1];
%         i=i+1;
%     end
% end
% l_indices = setdiff([1:length(time_ms)],nl_indices);
% time_ms(nl_indices,2) = interp1(l_indices,time_ms(l_indices,2),nl_indices,'linear','extrap');
% time_ms(:,2) = round(time_ms(:,2));
% time_ms(:,3) = time_ms(:,2)-time_ms(1,2);
% timestamp_camera = seconds(time_ms(:,3)/1000);
% gps_times_camera = datetime(2023,04,20,16,56,06,0,"Format","dd-MMM-uuuu HH:mm:ss.SSS") + timestamp_camera;
%% solution for 20230517T143053_867648049628025_r141355436_x365y250 video file.
% for i=1:length(time_ms)
%     if(time_ms(i,1)>=141359340 && time_ms(i,1)<=141465620)
%         time_ms(i,2) = time_ms(i,1);
%     else
%         time_ms(i,2)=0;
%     end
%     if(floor(time_ms(i,1)/100000000)==4)
%         time_ms(i,2) = time_ms(i,1)-300000000;
%     end
% end
% % Find the indices of non-zero elements
% nonzero_indices = find(time_ms(:,2) ~= 0);
% % Find the indices of zero elements
% zero_indices = find(time_ms(:,2) == 0);
% % interpolation
% time_ms(zero_indices,2) = interp1(nonzero_indices,time_ms(nonzero_indices,2),zero_indices,'linear','extrap');
% time_ms(:,2) = round(time_ms(:,2)); 
% nl_indices = [];
% for i=1:length(time_ms)-1
%     if(abs(time_ms(i+1,2)-time_ms(i,2))>60)
%         nl_indices = [nl_indices;i+1];
%     end
% end
% l_indices = setdiff([1:length(time_ms)],nl_indices);
% time_ms(nl_indices,2) = interp1(l_indices,time_ms(l_indices,2),nl_indices,'linear','extrap');
% time_ms(:,2) = round(time_ms(:,2));
% time_ms(:,3) = time_ms(:,2)-time_ms(1,2);
% timestamp_camera = seconds(time_ms(:,3)/1000);
% gps_times_camera = datetime(2023,05,03,16,30,53,180,"Format","dd-MMM-uuuu HH:mm:ss.SSS") + timestamp_camera;
%% solution for 20230517T142103_867648049628025_r140765248_x365y250 video file.
% for i=1:length(time_ms)
%     if(time_ms(i,1)>=140769544 && time_ms(i,1)<=141305053)
%         time_ms(i,2) = time_ms(i,1);
%     else
%         time_ms(i,2)=0;
%     end
%     if(floor(time_ms(i,1)/100000000)==4)
%         time_ms(i,2) = time_ms(i,1)-300000000;
%     end
% end
% % Find the indices of non-zero elements
% nonzero_indices = find(time_ms(:,2) ~= 0);
% % Find the indices of zero elements
% zero_indices = find(time_ms(:,2) == 0);
% % interpolation
% time_ms(zero_indices,2) = interp1(nonzero_indices,time_ms(nonzero_indices,2),zero_indices,'linear','extrap');
% time_ms(:,2) = round(time_ms(:,2)); 
% nl_indices = [];
% for i=1:length(time_ms)-1
%     if(abs(time_ms(i+1,2)-time_ms(i,2))>60)
%         nl_indices = [nl_indices;i+1];
%     end
% end
% l_indices = setdiff([1:length(time_ms)],nl_indices);
% time_ms(nl_indices,2) = interp1(l_indices,time_ms(l_indices,2),nl_indices,'linear','extrap');
% time_ms(:,2) = round(time_ms(:,2));
% time_ms(:,3) = time_ms(:,2)-time_ms(1,2);
% timestamp_camera = seconds(time_ms(:,3)/1000);
% gps_times_camera = datetime(2023,05,03,16,21,03,177,"Format","dd-MMM-uuuu HH:mm:ss.SSS") + timestamp_camera;
% %% to find frame no with matching IDs of me
% Ids = [1,16,25,26,27];
% frame_person = []; bbcoordinate = [];
% for i=1:length(time_ms)
%     try
%     detected_ids = [jsonfile.detection(i).objects.obj_id];
%     catch Error
%         detected_ids = [];
%     end
%     id = intersect(Ids,detected_ids);
%     if(id)
%         id=id(1);
%         frame_person = [frame_person;i]; 
%         posi = find(detected_ids==id,1);
%         bbcoordinate = [bbcoordinate; [jsonfile.detection(i).objects(posi).bbox]'];
%     end
% end
% time_person = gps_times_camera(frame_person);

%% solution for 20230503T114914_867648049628025_r2612651_x365y250 video file.
% % % to solve first few missing frames - extrapolation.
% % time_ms(1:51,2) = interp1([52:100],time_ms([52:100],1),[1:51],'linear','extrap');
% % time_ms(52,2) = time_ms(52,1); 
% % %to fill next set of value based on estimated difference
% % for i=53:length(time_ms)
% %     curr_diff = time_ms(i,1)-time_ms(i-1,2);
% %     if(curr_diff>10 && curr_diff<60)
% %         time_ms(i,2) = time_ms(i,1);
% %     else
% %         diff100 = rem(time_ms(i,1),100) - rem(time_ms(i-1,1),100);
% %         diff1000 = rem(time_ms(i,1),1000) - rem(time_ms(i-1,1),1000);
% %         diff10000 = rem(time_ms(i,1),10000) - rem(time_ms(i-1,1),10000);
% %         diff100000 = rem(time_ms(i,1),100000) - rem(time_ms(i-1,1),100000);
% %         curr_diff = max([diff100,diff1000,diff10000,diff100000]);
% %         if(diff100>10 && diff100<60)
% %             curr_diff = diff100;
% %         elseif(diff1000>10 && diff1000<60)
% %             curr_diff = diff1000;
% %         elseif(diff10000>10 && diff10000<60)
% %             curr_diff = diff10000;
% %         end
% %         if(curr_diff<=10)
% %             curr_diff = 33;
% %         elseif(curr_diff>60)
% %             curr_diff = 33;
% %         end
% %         time_ms(i,2) = time_ms(i-1,2) + curr_diff;
% %     end
% % end
% % time_ms(:,3) = time_ms(:,2)-time_ms(1,2);
% % timestamp_camera = seconds(time_ms(:,3)/1000); 
% % % convert epoch to gpstimes datetime(t, 'ConvertFrom', 'epochtime', 'Format', 'dd-MMM-uuuu HH:mm:ss.SSS')
% % gps_times_camera = datetime(2023,05,03,16,21,03,177,"Format","dd-MMM-uuuu HH:mm:ss.SSS") + timestamp_camera;
% % plot(time_ms(:,2));
% % 
% % %% to find frame no with matching IDs of me
% % Ids = [1,63,75,79,80,82,84,85,86,87,89,91,94,99,160,170,174,175,181,182,185,189];
% % frame_person = []; bbcoordinate = [];
% % for i=1:length(time_ms)
% %     try
% %     detected_ids = [jsonfile.detection(i).objects.obj_id];
% %     catch Error
% %         detected_ids = [];
% %     end
% %     id = intersect(Ids,detected_ids);
% %     if(id)
% %         frame_person = [frame_person;i]; 
% %         posi = find(detected_ids==id,1);
% %         bbcoordinate = [bbcoordinate; [jsonfile.detection(i).objects(posi).bbox]'];
% %     end
% % end
% % time_person = gps_times_camera(frame_person);