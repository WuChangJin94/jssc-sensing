set -e

apt-get update && apt-get install -y tmux

export ROS_IP=192.168.10.134
export ROS_MASTER_URI=http://192.168.10.133:11311/

echo "ROS_IP set to $ROS_IP"
echo "ROS_MASTER_URI set to $ROS_MASTER_URI"

tmux new-session -d -s sensing_session

# 在 window 1 執行 nmea_navsat_driver
tmux rename-window -t sensing_session:0 'nmea_navsat_driver'
tmux send-keys -t sensing_session:0 'source /opt/ros/noetic/setup.bash; \
                                     source ~/moos-dawg-2024/catkin_ws/devel/setup.bash; \
                                     rosrun nmea_navsat_driver nmea_socket_driver _port:=5106 _device:=udp' C-m

# 在 window 2 執行 compass
tmux new-window -t sensing_session:1 -n 'compass'
tmux send-keys -t sensing_session:1 'source /opt/ros/noetic/setup.bash; \
                                     source ~/moos-dawg-2024/catkin_ws/devel/setup.bash; \
                                     roslaunch lt500_compass lt500_compass.launch' C-m

# 在 window 3 執行 formatted_msg_pkg
tmux new-window -t sensing_session:2 -n 'formatted_msg_pkg'
tmux send-keys -t sensing_session:2 'source /opt/ros/noetic/setup.bash; \
                                     source ~/moos-dawg-2024/catkin_ws/devel/setup.bash; \
                                     rosrun formatted_msg_pkg formatted_publisher.py' C-m


tmux new-window -t sensing_session:3 -n 'pointcloud'
tmux send-keys -t sensing_session:3 'source /opt/ros/noetic/setup.bash; \
                                     source ~/moos-dawg-2024/catkin_ws/devel/setup.bash; \
                                     roslaunch velodyne_pointcloud VLP16_points_js.launch' C-m


tmux new-window -t sensing_session:4 -n 'mavros'
tmux send-keys -t sensing_session:4 'source /opt/ros/noetic/setup.bash; \
                                     source ~/moos-dawg-2024/catkin_ws/devel/setup.bash; \
                                     roslaunch mavros apm.launch fcu_url:=/dev/ttyACM0:115200 gcs_url:=udp://:14556@127.0.0.1:14556; \
                                     rostopic echo /mavros/state; \
                                     rosservice call /mavros/set_mode "{base_mode: 0, custom_mode: 'GUIDED'}"; \
                                     rosservice call /mavros/cmd/arming "value: true"; \
                                     rosservice call /mavros/cmd/set_home "{current_gps: true}"' C-m


# 保持 container 不退出
tmux attach-session -t sensing_session
