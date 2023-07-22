# post-processing the video metadata json files
import argparse
import os
import json
from pandas import read_csv
from tqdm import tqdm

# Estimate if the uptime from the filename is correct
def est_delay(dataset, start_uptime):
    delays = []
    for c, i in enumerate(dataset["detection"]):
        c_delay = i["uptime"] - (start_uptime+int(dataset["detection"][c]["frame_number"])*100/3)
        if abs(c_delay)<100:
            delays.append(c_delay)

    return sum(delays)/len(delays)

file_name = "20230628T094338_867648049628025_r608870663_x365y250"

# Read the json file containing the video metadata
with open(os.path.join(r"D:\Master's thesis\Video data",file_name+".json")) as f:
    data = json.load(f)

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

file_name = "20230628T094338_867648049628025_r608870663_x365y250_python"
# Write the updated json file
with open(os.path.join(r"D:\Master's thesis\Video data",file_name+".json"), 'w') as f:
    json.dump(data, f, indent=6, allow_nan=True)
# # Write the updated json file
# with open(os.path.join(r"C:\Users\prahul\OneDrive - Chalmers\PhD Rahul\Dataset\metadata",file_name+".json"), 'w') as f:
#     json.dump(data, f, indent=6, allow_nan=True)