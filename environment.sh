source /opt/ros/noetic/setup.bash
source "$HOME/jssc-sensing/catkin_ws/devel/setup.bash"

# $1 = ROS_MASTER_IP (default: 192.168.10.134)
if [ $# -ge 1 ]; then
  export ROS_MASTER_IP="$1"
  echo "ROS_MASTER_IP set to $ROS_MASTER_IP"
  source set_ros_master.sh "$ROS_MASTER_IP"
else
  export ROS_MASTER_IP="192.168.10.134"
  source set_ros_master.sh "$ROS_MASTER_IP"
fi

# $2 = ROS_IP (default: 192.168.10.134)
if [ $# -ge 2 ]; then
  export ROS_IP="$2"
  echo "ROS_IP set to $ROS_IP"
  source set_ros_ip.sh "$ROS_IP"
else
  export ROS_IP="192.168.10.134"
  source set_ros_ip.sh "$ROS_IP"
fi