import cv2
import time
import numpy as np

# Open the video file
cap = cv2.VideoCapture('./example/20221119T094137_867648049517293_r137081442_x355y265.mp4')
cap_ani = cv2.VideoCapture('./example/path_plot.mp4')

fps = 30 # Frame rate of the video
w = 1440 # Width of the video
h = 532 # Height of the video
vid_writer = cv2.VideoWriter("save_path_smooth.mp4", cv2.VideoWriter_fourcc(*'h264'), fps, (w, h)) # Video writer object

# Read until video is completed
while(cap.isOpened()):
    # Capture frame-by-frame
    ret, frame = cap.read()
    cap_ret, cap_frame = cap_ani.read()
    if ret == True and cap_ret == True:
        if cap.get(cv2.CAP_PROP_POS_MSEC) > 28000 and cap.get(cv2.CAP_PROP_POS_MSEC) < 58000:
            
            # Display the resulting frame
            img = np.zeros((532,1440,3), np.uint8)
            img[0:532, 0:720] = frame[0:532, 0:720]
            img[0:532, 720:1440] = cap_frame[0:532, 180:900]
            cv2.imshow('Frame', img)
            # Press Q on keyboard to  exit
            vid_writer.write(img)
            cv2.waitKey(1)
    # Break the loop
    else:
        break

# write the output frame to disk
vid_writer.release()
cap.release()
cap_ani.release()

