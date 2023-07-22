%% Lidar preprocessing : Ground Removal + Denoise + Downsample (?) + Removing Invalid points + selecting points in ROI
function [pc_new] = lidar_preprocessing(pc_old,roi)
ground = segmentGroundFromLidarData(pc_old);
pc_new = select(pc_old,~ground); % select non ground points - LIDAR to be placed Horizontally 
pc_new = removeInvalidPoints(pc_new); % remove invalid points
pc_new = pcdenoise(pc_new); % denoise
pc_new = pcdownsample(pc_new,'random',0.90); % downsize by 10 %

% selecting points in roi

pc_new = select(pc_new,findPointsInROI(pc_new,roi));
% returns unorganised point cloud.
end
