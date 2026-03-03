# moos-dawg-2024


## Clone repo 

```
git clone --recursive git@github.com:ARG-NCTU/moos-dawg-2024.git
``` 

## Update repo and submodules

```bash
git pull
git submodule sync --recursive
git submodule update --init --recursive
```

## Set up Docker
The requried dependencies are installed, you only need a PC with GPU, and make sure it install docker already.

## Set up Environment

1. Docker Run

    Run this script to pull docker image to your workstation.

    ```
    source Docker/gpu/gpu_run.sh
    ```

2. Docker Join

    If want to enter same docker image, type below command.

    ```
    source Docker/gpu/gpu_run.sh
    ```

3. Building MOOS

    Execute the compile script at first time, then the other can ignore this step. 

    ```
    source build_moos_base.sh
    source build_moos_arg.sh
    ```

4. Setup environment

    Make sure run this command when the terminal enter docker. 

    ```
    source environment.sh
    ```

5. Building ROS package
    Execute the compile script at first time, then the other can ignore this step. 

    ```
    cd catkin_ws
    catkin clean
    catkin build
    ```

6. Setup environment

    Make sure run this command when the terminal enter docker. 

    ```
    source environment.sh
    ```

## MOOS Example

1. Enter docker then go to the example of MOOS

    ```
    source Docker/gpu/gpu_run.sh
    cd arg-moos/mission/duckie/virtual_blueboat
    ```

2. Start MOOS-IvP

    ```
    ./launch.sh
    ```

3. Then press Deploy to run the behavior you write in the *.bhv file, or Return

4. If you want to change the waypoint, then you'll need to modify the .bhv inside the same folder(virtual_wamv).

## MOOS ROS Unity example



1. Ubuntu

    First terminal

    ```
    source Docker/gpu/gpu_run.sh
    source environment.sh <rosmaster_ip> <ros_ip>
    cd arg-moos/missions/bravo/ros_ctrl
    ./launch.sh
    ```

    Second terminal

    ```
    source Docker/gpu/gpu_run.sh
    source environment.sh <rosmaster_ip> <ros_ip>
    roslaunch moos_wamv_control moos_ctrler.launch virtual:=True
    ```

    Third terminal

    ```
    source Docker/gpu/gpu_run.sh
    source environment.sh <rosmaster_ip> <ros_ip>
    roslaunch rosbridge_server rosbridge_websocket.launch
    ```

## MOOS ROS Unity Real example
Note that sometimes after launched px4 still can get msg. \
Then you'll need to open QGC to trigger px4. \
Make sure your px4 launch file has the currect gcs_url(ip to open QGC).

1. Vehcicle for Original point

    First terminal

    ```
    source Docker/gpu/gpu_run.sh
    source environment.sh <rosmaster_ip> <ros_ip>
    roslaunch rosbridge_server rosbridge_websocket.launch
    ```

    Second terminal

    ```
    source Docker/gpu/gpu_run.sh
    source environment.sh <rosmaster_ip> <ros_ip>
    roslaunch sensor_pixhawk gps_wamv.launch
    ```

1. AR user

    First terminal

    ```
    source Docker/gpu/gpu_run.sh
    source environment.sh <rosmaster_ip> <ros_ip>
    roslaunch sensor_pixhawk gps_viewer.launch
    ```

    Second terminal

    ```
    source Docker/gpu/gpu_run.sh
    source environment.sh <rosmaster_ip> <ros_ip>
    roslaunch unity_joy_control unity_joy_control.launch
    ```


2. Base Station

    First terminal

    ```
    source Docker/gpu/gpu_run.sh
    source environment.sh <rosmaster_ip> <ros_ip>
    source source start_moos_procman.sh
    ```

    Second terminal

    ```
    source Docker/gpu/gpu_run.sh
    source environment.sh <rosmaster_ip> <ros_ip>
    cd arg-moos/missions/duckie/real_wamv
    ./launch.sh
    ```

    Third terminal

    ```
    source Docker/gpu/gpu_run.sh
    source environment.sh <rosmaster_ip> <ros_ip>
    source rosbag/record_veh_basestation.sh
    ```
    
    Fourth terminal
    
    <veh_name> decide which veh to initialize. \
    Normally is wamv-->viewer
    ```
    source Docker/gpu/gpu_run.sh
    source environment.sh <rosmaster_ip> <ros_ip>
    rosservice call /<veh name>/localization_pose/pose_initialize
    ```

    Fifth terminal
    
    ```
    source Docker/gpu/gpu_run.sh
    source environment.sh <rosmaster_ip> <ros_ip>
    source rosbag/record_images.sh
    ```


## BlueBoat Demo


1. Nano

    First terminal \
    moos-ivp for boat control.

    ```
    source Docker/autonomy/run.sh
    source environment_demo.sh
    cd arg-moos/mission/duckie/nano_blueboat
    ./launch
    ```

    Second terminal \
    moos ros bridge.

    ```
    source Docker/autonomy/run.sh
    source environment_demo.sh
    roslaunch moos_ctrler_nano.launch
    ```

2. BaseStation (192.168.2.*)

    First terminal \
    Localization of blueboat coordinate. \
    Remember to run pose initialize. \
    (call /wamv/localization_pose/pose_initialize)

    ```
    source Docker/gpu/gpu_run.sh
    source environment_demo.sh
    roslaunch localization localization_pose_blueboat.launch
    ```

    Second terminal \
    BlueBoat joystick and control signal.

    ```
    source Docker/gpu/gpu_run.sh
    source environment_demo.sh
    roslaunch moos_wamv_control blueboat_mavlink_joy.launch
    ```

    Third terminal \
    moos-ivp for basestation.

    ```
    source Docker/gpu/gpu_run.sh
    source environment_demo.sh
    cd arg-moos/mission/basestation/nano_blueboat
    ./launch
    ```


    Fourth terminal \
    QGC visualize.

    ```
    ./QGroundControl.AppImage
    ```

3. BaseStation (192.168.0.*)

    First terminal \
    Roscore.

    ```
    source Docker/gpu/gpu_run.sh
    source environment.sh 192.168.0.33
    roscore
    ```

    Second terminal \
    Rosbridge.

    ```
    source Docker/gpu/gpu_run.sh
    source environment.sh 192.168.0.33
    roslaunch rosbridge_server rosbridge_websocket.launch 
    ```

    Third terminal \
    Viewer localization. \
    Remember to run pose initialize after blueboat. (call /viewer/localization_pose/pose_initialize)
    ```
    source Docker/gpu/gpu_run.sh
    source environment.sh 192.168.0.33
    roslaunch localization localization_pose_viewer.launch 
    ```

4. AR user

    First terminal

    ```
    source Docker/gpu/gpu_run.sh
    source environment.sh <rosmaster_ip> <ros_ip>
    roslaunch sensor_pixhawk gps_viewer.launch
    ```