function pc_rot = pc_rotation(pc,angle)
%angle = pi/6;
% create rotation matrix for xy plane
rotMat = [cos(angle) -sin(angle)
          sin(angle) cos(angle)];

xy = pc.Location(:,1:2);
% rotate the xy coordinates using rotation matrix
rotatedXY = xy * rotMat;
% replace the original xy coordinates with rotated coordinates
pc_rot = pointCloud([rotatedXY,pc.Location(:,3)]);
pc_rot.Intensity = pc.Intensity;
end