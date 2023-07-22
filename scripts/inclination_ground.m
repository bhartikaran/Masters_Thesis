% to find inclination of ground with respect to XYZ axis
function [angle_degZ,angle_degY,angle_degX] = inclination_ground(pc)
ground = segmentGroundFromLidarData(pc);
groundpc = select(pc,ground);
% fit a plane
[model,inlier,outlier] = pcfitplane(groundpc,0.01);
z = [0 0 1];x = [1 0 0]; y=[0 1 0];
dot_pz = dot(model.Normal,z);
dot_px = dot(model.Normal,x);
dot_py = dot(model.Normal,y);
angle_degZ = acosd(dot_pz);
angle_degZ = min(angle_degZ,180-angle_degZ);
angle_degX = acosd(dot_px);
angle_degX = min(angle_degX,180-angle_degX);
angle_degY = acosd(dot_py);
angle_degY = min(angle_degY,180-angle_degY);
end