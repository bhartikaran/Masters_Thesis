# function to get the track of each object in the video
def get_track(cur_data, category_names= ['person', 'bicycle', 'car', 'motorcycle', 'airplane', 'bus', 'train', 'truck'], segmentation=False):
    track_dict = dict()

    for i in cur_data["detection"]:
        for j in i["objects"]:
            x1, y1, x2, y2 = j["bbox"]
            if not category_names[j["category_id"]] in track_dict:
                track_dict[category_names[j["category_id"]]] = dict()
                track_dict[category_names[j["category_id"]]][j["obj_id"]]=dict()
                track_dict[category_names[j["category_id"]]][j["obj_id"]]["start_uptime"] = i["uptime"]
                track_dict[category_names[j["category_id"]]][j["obj_id"]]["frame_count"] = []
                track_dict[category_names[j["category_id"]]][j["obj_id"]]["frame_count"].append(i["frame_number"])
                track_dict[category_names[j["category_id"]]][j["obj_id"]]["obj_track"] = []
                track_dict[category_names[j["category_id"]]][j["obj_id"]]["obj_track"].append(j["bbox"])
                track_dict[category_names[j["category_id"]]][j["obj_id"]]["scooter_speed"] = []
                track_dict[category_names[j["category_id"]]][j["obj_id"]]["scooter_speed"].append(i["speed"])
                track_dict[category_names[j["category_id"]]][j["obj_id"]]["scooter_gps"] = []
                track_dict[category_names[j["category_id"]]][j["obj_id"]]["scooter_gps"].append(i["gps"])
                if segmentation:
                    track_dict[category_names[j["category_id"]]][j["obj_id"]]["obj_segmentation"] = []
                    track_dict[category_names[j["category_id"]]][j["obj_id"]]["obj_segmentation"].append(j["closest_point"])
            else:
                if not j["obj_id"] in track_dict[category_names[j["category_id"]]]:
                    track_dict[category_names[j["category_id"]]][j["obj_id"]]=dict()
                    track_dict[category_names[j["category_id"]]][j["obj_id"]]["start_uptime"] = i["uptime"]
                    track_dict[category_names[j["category_id"]]][j["obj_id"]]["frame_count"] = []
                    track_dict[category_names[j["category_id"]]][j["obj_id"]]["frame_count"].append(i["frame_number"])
                    track_dict[category_names[j["category_id"]]][j["obj_id"]]["obj_track"] = []
                    track_dict[category_names[j["category_id"]]][j["obj_id"]]["obj_track"].append(j["bbox"])
                    track_dict[category_names[j["category_id"]]][j["obj_id"]]["scooter_speed"] = []
                    track_dict[category_names[j["category_id"]]][j["obj_id"]]["scooter_speed"].append(i["speed"])
                    track_dict[category_names[j["category_id"]]][j["obj_id"]]["scooter_gps"] = []
                    track_dict[category_names[j["category_id"]]][j["obj_id"]]["scooter_gps"].append(i["gps"])
                    if segmentation:
                        track_dict[category_names[j["category_id"]]][j["obj_id"]]["obj_segmentation"] = []
                        track_dict[category_names[j["category_id"]]][j["obj_id"]]["obj_segmentation"].append(j["closest_point"])
                else:
                    track_dict[category_names[j["category_id"]]][j["obj_id"]]["frame_count"].append(i["frame_number"])
                    track_dict[category_names[j["category_id"]]][j["obj_id"]]["obj_track"].append(j["bbox"])
                    track_dict[category_names[j["category_id"]]][j["obj_id"]]["scooter_speed"].append(i["speed"])
                    track_dict[category_names[j["category_id"]]][j["obj_id"]]["scooter_gps"].append(i["gps"])
                    if segmentation:
                        track_dict[category_names[j["category_id"]]][j["obj_id"]]["obj_segmentation"].append(j["closest_point"])
            

    return track_dict
