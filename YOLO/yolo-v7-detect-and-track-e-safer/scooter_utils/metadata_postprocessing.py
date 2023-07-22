# post-processing the video metadata json files
import argparse
import json
from pandas import read_csv

# Estimate if the uptime from the filename is correct
def est_delay(dataset, start_uptime):
    delays = []
    for c, i in enumerate(dataset["detection"]):
        c_delay = i["uptime"] - (start_uptime+int(dataset["detection"][c]["frame_number"])*100/3)
        if abs(c_delay)<100:
            delays.append(c_delay)

    return sum(delays)/len(delays)

# arg parser
parser = argparse.ArgumentParser(description='Process distance estimation')
parser.add_argument('--file_name', type=str, help='file name')

args = parser.parse_args()

# Read the csv file that contains the file names and the corresponding parameters
file_list = read_csv('matched_rides.csv', engine='python')

if args.file_name:
    file_list = file_list[file_list.synced_file_name == args.file_name]

# reset the index of the dataframe
file_list = file_list.reset_index(drop=True)

# Loop through the file names and update the json files
for i, file_name in (enumerate(file_list.synced_file_name)):
    # Read the csv file that contains the kinematic data
    raw_scooter_data = read_csv(file_name+".csv", delimiter=" |\t|,", skiprows=[1, 2], engine='python')
    
    # Read the json file containing the video metadata
    with open(file_name+".json") as f:
        data = json.load(f)
    
    # Update the json file with the corresponding parameters
    data["filename"] = str(file_name)
    data["average_speed"] = float(file_list.avg_speed[i])
    data["video_data_delay"] = int(file_list.video_data_delay[i])
    data["bluriness"] = float(file_list.video_blur[i])
    data["brightness"] = float(file_list.video_brightness[i])

    # Determine the start uptime of the video and possible delay with the uptime from the filename
    start_uptime = int(file_name.split("r")[1].split("_")[0])
    delay_comp = est_delay(data, start_uptime)

    # Update the uptime for each frame in the json file
    for c, j in enumerate(data["detection"]):
        if j["uptime"] == -1:
            data["detection"][c]["uptime"] = int(start_uptime+int(data["detection"][c]["frame_number"])*100/3+delay_comp)
        else:
            c_delay = j["uptime"] - (start_uptime+int(data["detection"][c]["frame_number"])*100/3)
            if abs(c_delay)>100:
                data["detection"][c]["uptime"] = int(start_uptime+int(data["detection"][c]["frame_number"])*100/3+delay_comp)
    
    # Update the speed and gps for each frame in the json file
    for c, _ in enumerate(data["detection"]):
        ind_match = raw_scooter_data.iloc[(raw_scooter_data.t-data["detection"][c]["uptime"]).abs().argsort()[0],:].name
        
        data["detection"][c]["speed"] = int(raw_scooter_data.v_wheel[ind_match])
        data["detection"][c]["gps"] = [float(raw_scooter_data.lon[ind_match]), float(raw_scooter_data.lat[ind_match])]

    # Write the updated json file
    with open(file_name+".json", 'w') as f:
        json.dump(data, f, indent=6, allow_nan=True)
