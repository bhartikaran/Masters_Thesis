%% to try out height thresholding for pedestrian detection!
function [max_height,min_height,height] = height_threshold(pc_new,labels,x)
idx = find(abs(pc_new.Location(:,1)-x)<1e-4);
idx = idx(1);
segment_no = labels(idx);
segment = find(labels==segment_no);
max_height = max(pc_new.Location(segment,3));
min_height = min(pc_new.Location(segment,3));
height = max_height-min_height;
end
