from func_dist_est import get_dist
from func_get_track import get_track
import json
from datetime import timedelta

def process_distance_estimation(file_name, category_names, segmentation, verbose):
    # Get the start uptime of the video
    start_uptime = int(file_name.split("r")[1].split("_")[0])

        # Read the post processed json file containing the video metadata
    with open(file_name+".json") as f:
        cur_data = json.load(f)

    # calculate the lens center of the video
    try:
        cur_center_x = int(file_name.split("_x")[1][:3])
    except:
        cur_center_x = 360

    # transform the frame based detection to object based detection
    track_dict = get_track(cur_data, category_names, segmentation)

    # calculate the distance and angle of each object in each frame
    for i in track_dict:
        for j in track_dict[i]:
            crash_flag = False
            track_dict[i][j]["obj_distance"] = []
            track_dict[i][j]["obj_angle"] = []
            for k in range(len(track_dict[i][j]["obj_track"])):
                x1, y1, x2, y2 = track_dict[i][j]["obj_track"][k]
                if segmentation:
                    dx1, dy1 = track_dict[i][j]["obj_segmentation"][k]
                    if dx1 == 0 and dy1 == 0 and k > 0:
                        # TODO: Update the position of the closest_point in the main json file
                        dx1, dy1 = track_dict[i][j]["obj_segmentation"][k-1]
                    cur_dist, _ = get_dist(dx1, dy1, cur_center_x)
                    _, cur_angle = get_dist((x1+x2)/2, y2, cur_center_x)
                else:
                    if i == "person":
                        cur_dist, cur_angle = get_dist((x1+x2)/2, y2, cur_center_x)
                    else:
                        if x1<cur_center_x:
                            cur_dist, cur_angle = get_dist(x2, y2, cur_center_x)
                            #_, _ = get_dist((x1+x2)/2, y2, cur_center_x)
                        else:
                            cur_dist, cur_angle = get_dist(x1, y2, cur_center_x)
                            #_, cur_angle = get_dist((x1+x2)/2, y2, cur_center_x)
                    
                track_dict[i][j]["obj_distance"].append(cur_dist)
                track_dict[i][j]["obj_angle"].append(cur_angle)
                if verbose and cur_dist < 1 and track_dict[i][j]["scooter_speed"][k] > 10 and not crash_flag:
                    print("Warning: "+i+" "+str(j)+" close to scooter", track_dict[i][j]["frame_count"][-1], timedelta(milliseconds= cur_data["detection"][track_dict[i][j]["frame_count"][-1]]["uptime"]-start_uptime), cur_dist, cur_angle)
                    crash_flag = True

    # replace the frame based detection with object based detection
    cur_data["detection"] = track_dict

    return cur_data
