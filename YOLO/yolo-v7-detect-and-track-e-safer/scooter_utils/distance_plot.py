import argparse
import json
import numpy as np
import cv2
import pandas as pd
from scipy import signal
import math

from func_process_distance_estimation import process_distance_estimation

# Argument parser
parser = argparse.ArgumentParser(description='Process distance estimation')
parser.add_argument('-f','--file_name', type=str, required=True, help='Path to the json file')
parser.add_argument('-seg','--segmentation', action="store_true", help="segmentation used for annotation")
parser.add_argument('--speed',help="Embed the speed of the scooter")

args = parser.parse_args()

file_name = args.file_name

segmentation = args.segmentation


# Category names used for annotation
# NOTE: The order of the category names should be the same as the order of the category ids in the json file
category_names = ['person', 'bicycle', 'car', 'motorcycle', 'airplane', 'bus', 'train', 'truck']


# Read the post processed json file containing the video metadata
with open(file_name+".json") as f:
    org_data = json.load(f)

# categorize the data from the json file
cat_data = process_distance_estimation(file_name, category_names, segmentation, verbose = False)

# Function to smooth the data
# fc = 1.5  # Cut-off frequency of the filter
# fs = 30 # Original frequency of collection
# w = fc / (fs / 2) # Normalize the frequency
# c,d = signal.butter(2, w, 'low') # Butterworth filter of order 2

# Smoothen the data
# for i in cat_data["detection"]:
#     for j in cat_data["detection"][i]:
#         for k in cat_data["detection"][i][j]:
#             if len(cat_data["detection"][i][j]["obj_distance"]) > 9 and max(cat_data["detection"][i][j]["obj_distance"]) != float("inf"):
#                 cat_data["detection"][i][j]["obj_distance"] = list(signal.filtfilt(c, d, cat_data["detection"][i][j]["obj_distance"]))

for i in cat_data["detection"]:
    for j in cat_data["detection"][i]:
        # for k in cat_data["detection"][i][j]:
            #print(i,j)
            cat_data["detection"][i][j]["obj_distance"] = pd.Series(cat_data["detection"][i][j]["obj_distance"]).rolling(int(10), min_periods=1, center=True).mean().tolist()

            if args.speed == True:
                obj_distance = pd.Series(cat_data["detection"][i][j]["obj_distance"])
                obj_angle = pd.Series(cat_data["detection"][i][j]["obj_angle"])

                obj_dist_shifted = obj_distance.shift().fillna(obj_distance[0])
                obj_angle_shifted = obj_angle.shift().fillna(obj_angle[0])

                obj_speed = (obj_dist_shifted*obj_angle_shifted.apply(lambda x: math.sin(np.deg2rad(x)) if x !=float("inf") else 0)-obj_distance*obj_angle.apply(lambda x: math.sin(np.deg2rad(x)) if x !=float("inf") else 0))**2+(obj_dist_shifted*obj_angle_shifted.apply(lambda x: math.cos(np.deg2rad(x)) if x !=float("inf") else 1)-obj_distance*obj_angle.apply(lambda x: math.cos(np.deg2rad(x))if x !=float("inf") else 1))**2

                # obj_speed = obj_dist_shifted**2+obj_distance**2-2*obj_dist_shifted*obj_distance*(obj_angle_shifted.apply(lambda x: math.sin(x) if x !=float("inf") else 0)*obj_angle.apply(lambda x: math.sin(x) if x !=float("inf") else 0)+obj_angle_shifted.apply(lambda x: math.cos(x) if x !=float("inf") else 1)*obj_angle.apply(lambda x: math.cos(x)if x !=float("inf") else 1))
                #print(obj_speed)
                obj_speed = obj_speed.apply(lambda x: math.sqrt(x))*3.6*30
                cat_data["detection"][i][j]["obj_speed"] = obj_speed.rolling(int(10), min_periods=1, center=True).mean().tolist()

            


# Create a video writer object
fps = 30 # Frame rate of the video
w = 1080 # Width of the video
h = 532 # Height of the video
vid_writer = cv2.VideoWriter(f"{file_name}_visualised.mp4", cv2.VideoWriter_fourcc(*'mp4v'), fps, (w, h)) # Video writer object

# List all the detected objects in the video
for i in org_data["detection"]:
    
    # create an image of dimension 1080x532
    img = np.zeros((532,1080,3), np.uint8)

    # For every object detected in the frame
    for j in i["objects"]:
        # Get the categorized data for the object
        try:
            cur_data = cat_data["detection"][category_names[j["category_id"]]][j["obj_id"]]
        except:
            cur_data = cat_data["detection"][category_names[j["category_id"]]][str(j["obj_id"])]
        
        # Get the distance and angle of the object for the current frame
        cur_distance = cur_data["obj_distance"][cur_data["frame_count"].index(i["frame_number"])]
        cur_angle = cur_data["obj_angle"][cur_data["frame_count"].index(i["frame_number"])]
        
        
        # If the distance and angle are not infinity or NaN
        if not (cur_distance == float("inf") or cur_angle == float("inf") or math.isnan(cur_distance) or math.isnan(cur_angle)):
            
            cur_x = cur_distance * np.sin(np.deg2rad(cur_angle))
            cur_y = cur_distance * np.cos(np.deg2rad(cur_angle))
            # Assign the color of the circle based on the category of the object
            if j["category_id"] == 0:
                circ_color = (182,226,255)
            elif j["category_id"] == 1:
                circ_color = (45,196,100)
            elif j["category_id"] == 2:
                circ_color= (196,114,45)
            else:
                circ_color = (0,0,255)
            
            cv2.circle(img, (int(cur_x*50)+540,500-int(cur_y*50)), 9, circ_color, -1)

            # Write the object information on the image
            if args.speed == True:
                cur_speed = cur_data["obj_speed"][cur_data["frame_count"].index(i["frame_number"])]
                cur_scooter_speed = cur_data["scooter_speed"][cur_data["frame_count"].index(i["frame_number"])]
                cv2.putText(img, str(j["obj_id"])+" "+str(round(cur_speed,1))+" "+str(round(cur_scooter_speed,1)), (540+int(cur_x*50)-5,500-int(cur_y*50)-10), 0, 0.45, [225, 255, 255], thickness=1, lineType=cv2.LINE_AA)
            else:
                cv2.putText(img, str(j["obj_id"]), (540+int(cur_x*50)-5,500-int(cur_y*50)-10), 0, 0.45, [225, 255, 255], thickness=1, lineType=cv2.LINE_AA)
                
    # Draw the scooter
    cv2.rectangle(img, (520,500), (560,532), (97, 105, 242), -1)

    # Add a legend to the image
    cv2.circle(img, (950,20), 7, (182,226,255), -1)
    cv2.putText(img, "person", (970,25), 0, 0.75, [225, 255, 255], thickness=1, lineType=cv2.LINE_AA)
    cv2.circle(img, (950,50), 7, (45,196,100), -1)
    cv2.putText(img, "bicycle", (970,55), 0, 0.75, [225, 255, 255], thickness=1, lineType=cv2.LINE_AA)
    cv2.circle(img, (950,80), 7, (196,114,45), -1)
    cv2.putText(img, "car", (970,85), 0, 0.75, [225, 255, 255], thickness=1, lineType=cv2.LINE_AA)
    cv2.circle(img, (950,110), 7, (0,0,255), -1)
    cv2.putText(img, "other", (970,115), 0, 0.75, [225, 255, 255], thickness=1, lineType=cv2.LINE_AA)

    # write the image to a video file
    vid_writer.write(img)
    
    #resize image
    #img = cv2.resize(img, (540, 266))

    # Display the image
    cv2.imshow("img",img)
    cv2.waitKey(1)
vid_writer.release()

