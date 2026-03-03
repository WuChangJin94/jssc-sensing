cmake_minimum_required(VERSION 3.0.2)
project(formatted_publisher)

find_package(catkin REQUIRED COMPONENTS
  rospy
  std_msgs
  geometry_msgs
  sensor_msgs
)

catkin_package()

catkin_install_python(
  PROGRAMS src/formatted_publisher_node.py
  DESTINATION ${CATKIN_PACKAGE_BIN_DESTINATION}
)
