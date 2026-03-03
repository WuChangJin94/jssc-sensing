# syntax=docker/dockerfile:1

ARG DIST=noetic

# ------------------------------------------------------------
# Base image for amd64 IPC (Ubuntu 20.04)
# ------------------------------------------------------------
FROM ubuntu:20.04

ARG DIST=noetic

ENV DEBIAN_FRONTEND=noninteractive \
    ROS_DISTRO=${DIST} \
    SHELL=/bin/bash \
    TZ=Etc/UTC

# ------------------------------------------------------------
# Base utilities
# ------------------------------------------------------------
RUN apt-get update && apt-get install -y --no-install-recommends \
        tzdata \
        ca-certificates \
        build-essential \
        cmake \
        cppcheck \
        curl \
        git \
        gnupg \
        gdb \
        psmisc \
        vim \
        nano \
        tmux \
        libeigen3-dev \
        libgles2-mesa-dev \
        lsb-release \
        pkg-config \
        protobuf-compiler \
        python3-dbg \
        python3-pip \
        python3-scipy \
        python3-venv \
        python3-dev \
        python3-setuptools \
        qtbase5-dev \
        netbase \
        net-tools \
        iputils-ping \
        ruby \
        software-properties-common \
        sudo \
        wget \
        can-utils \
        socat \
        netcat-openbsd \
    && ln -snf /usr/share/zoneinfo/${TZ} /etc/localtime \
    && echo ${TZ} > /etc/timezone \
    && rm -rf /var/lib/apt/lists/*

# ------------------------------------------------------------
# ROS1 apt repo + key
# ------------------------------------------------------------
RUN mkdir -p /usr/share/keyrings && \
    curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.asc \
      | gpg --dearmor -o /usr/share/keyrings/ros-archive-keyring.gpg && \
    echo "deb [signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] \
      http://packages.ros.org/ros/ubuntu focal main" \
      > /etc/apt/sources.list.d/ros1-latest.list

# ------------------------------------------------------------
# ROS tools
# ------------------------------------------------------------
RUN apt-get update && apt-get install -y --no-install-recommends \
        python3-rosdep \
        python3-rosinstall \
        python3-rosinstall-generator \
        python3-vcstool \
        python3-catkin-tools \
    && rm -rf /var/lib/apt/lists/*

RUN rosdep init 2>/dev/null || true && rosdep update

# ------------------------------------------------------------
# Install ROS Noetic + packages
# ------------------------------------------------------------
RUN apt-get update && apt-get install -y --no-install-recommends \
        ros-${ROS_DISTRO}-desktop \
        ros-${ROS_DISTRO}-rosbag \
        ros-${ROS_DISTRO}-robot-localization \
        ros-${ROS_DISTRO}-robot-state-publisher \
        ros-${ROS_DISTRO}-joint-state-publisher \
        ros-${ROS_DISTRO}-joint-state-controller \
        ros-${ROS_DISTRO}-effort-controllers \
        ros-${ROS_DISTRO}-geographic-info \
        ros-${ROS_DISTRO}-teleop-tools \
        ros-${ROS_DISTRO}-teleop-twist-joy \
        ros-${ROS_DISTRO}-teleop-twist-keyboard \
        ros-${ROS_DISTRO}-joy \
        ros-${ROS_DISTRO}-joy-teleop \
        ros-${ROS_DISTRO}-xacro \
        ros-${ROS_DISTRO}-pcl-conversions \
        ros-${ROS_DISTRO}-pcl-ros \
        ros-${ROS_DISTRO}-velodyne \
        ros-${ROS_DISTRO}-velodyne-pointcloud \
        ros-${ROS_DISTRO}-velodyne-driver \
        ros-${ROS_DISTRO}-velodyne-laserscan \
        ros-${ROS_DISTRO}-image-transport \
        ros-${ROS_DISTRO}-compressed-image-transport \
        ros-${ROS_DISTRO}-ddynamic-reconfigure \
        ros-${ROS_DISTRO}-rosserial \
        ros-${ROS_DISTRO}-rosserial-arduino \
        ros-${ROS_DISTRO}-socketcan-interface \
        ros-${ROS_DISTRO}-catkin-virtualenv \
        ros-${ROS_DISTRO}-nmea-navsat-driver \
    && rm -rf /var/lib/apt/lists/*

# ------------------------------------------------------------
# Source ROS automatically
# ------------------------------------------------------------
RUN echo "source /opt/ros/${ROS_DISTRO}/setup.bash" >> /root/.bashrc

CMD ["/bin/bash"]