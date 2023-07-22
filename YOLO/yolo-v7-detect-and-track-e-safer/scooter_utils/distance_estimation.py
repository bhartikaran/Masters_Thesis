import argparse
import json
from func_dist_est import get_dist
from func_get_track import get_track
from func_process_distance_estimation import process_distance_estimation

from pandas import read_csv

# arg parser
parser = argparse.ArgumentParser(description='Process distance estimation')
parser.add_argument('--file_name', type=str, help='file name')
parser.add_argument('--segmentation', action="store_true", help="segmentation used for annotation")

args = parser.parse_args()

# Category names used for annotation
# NOTE: The order of the category names should be the same as the order of the category ids in the json file
category_names = ['person', 'bicycle', 'car', 'motorcycle', 'airplane', 'bus', 'train', 'truck']

# If segmentation used for annotation
segmentation = args.segmentation

# Read the csv file that contains the file names and the corresponding parameters
file_list = read_csv('matched_rides.csv', engine='python')

if args.file_name:
    file_list = file_list[file_list.synced_file_name == args.file_name]

# Loop through the file names and update the json files
for file_name in file_list.synced_file_name:

    # process the distance estimation
    cur_data = process_distance_estimation(file_name, category_names, segmentation, True)

    # save the updated categorized json filels
    
    with open(file_name+'_categorized.json', 'w') as f:
        json.dump(cur_data, f, indent=6, allow_nan=True)

