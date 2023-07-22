# Yolo V7 detect and track

## Object detection and tracking
The object detection is based on the [WongKinYiu's Yolov7](https://github.com/WongKinYiu/yolov7)
The detection and tracking is based on the work done by [haroonshakeel](https://github.com/haroonshakeel/yolov7-object-tracking)

### Installing the libraries
Install all the requirements using the command
```
pip3 install requirements.txt
```

If usign a GPU then install the requirements using
```
pip3 install requirements_gpu.txt
```

### Running the detection and tracking
To run the basic object detection use the command
```
python3 detect_or_track.py --weight yolov7x.pt --conf 0.6 --classes 0 1 2 --img-size 640 --source yourfile.mp4
```
The --classes flag indicate the classes that you wish to detect. The entire list can be found in the [YAML file](./data/coco.yaml) 

To run the the object tracking use the command
Note: This will add a tracking line at the center of the bounding box
```
python3 detect_or_track.py --weight yolov7x.pt --conf 0.6 --classes 0 1 2 --img-size 640 --source yourfile.mp4 --show-track
```

To run the the object tracking but not add a tracking line use the command
```
python3 detect_or_track.py --weight yolov7x.pt --conf 0.6 --classes 0 1 2 --img-size 640 --source yourfile.mp4 --track
```

To obtain the tracking at the bottom of the bounding box use the following command
```
python3 detect_or_track.py --weight yolov7x.pt --conf 0.6 --classes 0 1 2 --img-size 640 --source yourfile.mp4 --track --base-track
```

To save the annotations in a json file use the following command
```
python3 detect_or_track.py --weight yolov7x.pt --conf 0.6 --classes 0 --img-size 640 --source yourfile.mp4 --base-track --store-meta
```

To anonymize the video use the following command
```
python3 detect_or_track.py --weight yolov7x.pt --conf 0.6 --classes 0 2 --img-size 640 --source yourfile.mp4 --blurbox
```

To retain the audio of the original video use the following command
```
python3 detect_or_track.py --weight yolov7x.pt --conf 0.6 --classes 0 2 --img-size 640 --source yourfile.mp4 --blurbox --add-audio
```

## Command Line Args Reference
```
detect_or_track.py:
  --source: path to input video (use 0 for webcam)
    (default='inference/images')
  --classes: class id of the objects to be detected
    (default='inference/images')
  --weight: path to weights file
    (default='yolov7x.pt')
  --img-size: resize images to
    (default: 640)
  --conf: confidence threshold
    (default: 0.50)
  --track: track the center of the object and assign unique id
    (default: False)
  --base-track: track the base point of the object and assign unique id
    (default: False)
  --show-track: mark the track on the video output
    (default: False)
  --nobbox: prevent adding the bounding box in the video
    (default: False)
  --blackbox: add black box to anonymize object within bounding box
    (default: False)
  --faceonlybox: add black box to anonymize face
    (default: False)
  --blurbox: add blurred box to anonymize object within bounding box
    (default: False)
  --nolabel: don`t show label above the bounding box
    (default: False)
  --store-meta: store the metadata of the labels
    (default: False)
  --add-audio: add the audio from the original video to the exported video
    (default: False)
```

## Bugs and feature requests
<b>Head over to the issues tab and feel free to create one or drop an email [rahul.pai@chalmers.se]</b>

## Sharing and licencing
The work is based on repositories which is have the GNU General Public License v3.0. Hence it should be possible to share it freely but since I am not a lawyer, I recommend to avoid if possible.

## Credits
- [WongKinYiu Yolov7 Repo](https://github.com/WongKinYiu/yolov7)
- [RizwanMunawar Yolov7 Object Tracking Repo](https://github.com/RizwanMunawar/yolov7-object-tracking)
- [haroonshakeel YOLOv7 Object Tracking Repo](https://github.com/haroonshakeel/yolov7-object-tracking)
- [abewley SORT Repo](https://github.com/abewley/sort)
- [TheAIGuy DeepSort Repo](https://github.com/theAIGuysCode/yolov4-deepsort)

## TODO
- [x] Obtain the points of the trajectory
- [ ] Estimate the trajectory
- [ ] [Distance estimation](./scooter_utils) 
- [ ] Time to collision estimation
- [x] Add audio from source to the exported video
- [x] Save metadata of the objects detected

