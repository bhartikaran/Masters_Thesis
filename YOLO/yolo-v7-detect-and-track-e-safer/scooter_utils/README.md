# Distance estimation using the metadata
The aim here is to estimate the distance of the objects and flag in cases where distance is low

Improvements:
- [x] Fix the bug of object identity
- [x] Estimate distance to other objects
- [x] Combine with the wheel speed from the kinematic data
- [x] Disable the same object flagging a proximity warning
- [ ] Improve proximity warning for cars (Point on frame used to calculate distance)
- [ ] Create a good flow between each of the files

## How to use:<br>
Step 1: Run the YOLO model using the detect_and_track.py and obtain the metadata file<br>

Step 2: Run the metadata_preprocessing file that will fix all issues within the metadata file<br>

Step 3: Run the distance_estimation file that will calculate the distances and save it in the categorised file<br>

Step 4: Run the distance_plot file to obtain the video of the distance detections<br>

## Major changes:

47172a9d - Major overhaul of the scripts. Introduction of a new function file func_dist_estimation and is used both in distance estimation and distance plotting.

897cb5e2 - Adding the list of frame numbers instead as some objects are not in consecutive frames

0887dac9 - Going back to the object based detection as it facilitates the further TTC calculation

d6379f7f - Updated the distance estimation to work with the json file preprocessed using the metadata_postprocessing script

fa37a4fa - Initial object based detection of distance
            Advantages: Modifies the json from a frame based one to an object based one.
            Drawback: Code can be confusing to understand

Function files:
	func_dist_est: This function contains the pixel to distance transformation model
	func_get_track: Converts the frame based file to an object based file
	func_process_dist_estimation: Estimates the distance to every object within the ride and flags if there is any critical incident
		Dependencies: 	func_dist_est
				func_get_track
Main files:
	metadata_preprocessing: pre-processes the metadata obtained from the Yolo Model
		Dependencies: 	matched_rides.csv
				The datafile for the ride being processed
	
	distance_estimation: The distance to the object is estimated for all rides or specific ride and prints out the critical incident.
		Dependencies:	func_process_dist_estimation
				matched_rides.csv
	
	distance_plot: Similar to distance estimation but generates the video containing the visualisation of the distance and angle
		Dependencies:	func_process_dist_estimation
	
	video_combiner: Combines the original video and visualisation side by side. Can be used for presentation of the work etc.
		
