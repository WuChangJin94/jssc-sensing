# Use the official ROS Noetic base image
FROM osrf/ros:noetic-desktop

ARG DEBIAN_FRONTEND=noninteractive
ARG GAZ=gazebo11

# Set environment variables
ENV ROS_DISTRO=noetic \
    SHELL=/bin/bash \
    NB_USER=moos-dawg \
    NB_UID=1000 \
    HOME=/home/moos-dawg

# Create the user, set timezone, and set passwords
RUN echo 'Etc/UTC' > /etc/timezone && \
    ln -sf /usr/share/zoneinfo/Etc/UTC /etc/localtime && \
    adduser --disabled-password --gecos "Default user" --uid ${NB_UID} ${NB_USER} && \
    echo "root:root" | chpasswd && echo "${NB_USER}:111111" | chpasswd

# Install additional dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    curl vim wget sudo cmake gedit gnupg2 gtk+-3.0 locales dirmngr mercurial net-tools \
    build-essential libcanberra-gtk-module libcanberra-gtk3-module libpcap-dev \
    libusb-1.0 tzdata libglfw3-dev libmetis-dev python3-tk python3-pip python3-setuptools \
    python3-numpy python3-empy python3-opencv python3-venv python3-dev python3-yaml \
    libfltk1.3-dev freeglut3-dev libpng-dev libjpeg-dev libxft-dev libxinerama-dev \
    libtiff5-dev librapidxml-dev fluid xterm scrot g++ subversion libtiff-dev espeak \
    qtbase5-dev ifstat iperf3 git python3-rosdep python3-catkin-tools \
    apt-transport-https && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Install Velodyne and pcl_ros ROS packages
RUN apt-get update && \
    apt-get install -y \
    ros-$ROS_DISTRO-velodyne \
    ros-$ROS_DISTRO-velodyne-pointcloud \
    ros-$ROS_DISTRO-velodyne-driver \
    ros-$ROS_DISTRO-velodyne-laserscan \
    ros-$ROS_DISTRO-pcl-ros \
    ros-$ROS_DISTRO-mavros \
    ros-$ROS_DISTRO-mavros-extras \ 
    ros-$ROS_DISTRO-image-transport \
    ros-$ROS_DISTRO-compressed-image-transport \
    ros-$ROS_DISTRO-ddynamic-reconfigure&& \
    apt-get clean && rm -rf /var/lib/apt/lists/*


# Register the RealSense public key and repository
RUN mkdir -p /etc/apt/keyrings && \
    curl -sSf https://librealsense.intel.com/Debian/librealsense.pgp | tee /etc/apt/keyrings/librealsense.pgp > /dev/null && \
    echo "deb [signed-by=/etc/apt/keyrings/librealsense.pgp] https://librealsense.intel.com/Debian/apt-repo $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/librealsense.list && \
    apt-get update && \
    apt-get install -y librealsense2-dev



    

# Install RealSense packages
RUN apt-get update && \
    apt-get install -y librealsense2-dkms librealsense2-utils && \
    apt-get clean && rm -rf /var/lib/apt/lists/*
    
############################### MAVROS ######################################
RUN wget https://raw.githubusercontent.com/mavlink/mavros/master/mavros/scripts/install_geographiclib_datasets.sh \
    && sudo bash ./install_geographiclib_datasets.sh  

# Source ROS environment
RUN echo "source /opt/ros/${ROS_DISTRO}/setup.bash" >> ${HOME}/.bashrc && \
    echo "source ${HOME}/catkin_ws/devel/setup.bash" >> ${HOME}/.bashrc

# Final cleanup and setup
USER root
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

CMD ["/bin/bash"]

