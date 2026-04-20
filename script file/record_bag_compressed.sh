#!/bin/bash
# mount /dev/mmcblk1 /mnt/sandisk/


 rosbag record                  \
   /baton/CamL2Imu              \
   /baton/CamR2Imu              \
   /baton/camera_left_info      \
   /baton/camera_right_info     \
   /baton/image_left/compressed            \
   /baton/image_left_info       \
   /baton/image_right/compressed           \
   /baton/image_right_info      \
   /baton/imu                   \
   /baton/rtk                   \
   /rtk_nmea                    \
   /rtk_extrinsic               \
    -o rosbag.bag
