#!/bin/bash

#TODO: get this as a parameter
ZOEF_SRC_DIR=/usr/local/src/zoef

# Install ROS Melodic
sudo sh -c 'echo "deb http://packages.ros.org/ros/ubuntu $(lsb_release -sc) main" > /etc/apt/sources.list.d/ros-latest.list'
sudo apt-key adv --keyserver 'hkp://keyserver.ubuntu.com:80' --recv-key C1CF6E31E6BADE8868B172B4F42ED6FBAB17C654
sudo apt update
sudo apt install -y ros-melodic-ros-base python-rosinstall python-rosinstall-generator python-wstool build-essential python-catkin-tools
sudo rosdep init
rosdep update
grep -qxF "source /opt/ros/melodic/setup.bash" /home/zoef/.bashrc || echo "source /opt/ros/melodic/setup.bash" >> /home/zoef/.bashrc
source /opt/ros/melodic/setup.bash

# Install computer vision libraries
#TODO: make dependecies of ROS package
sudo apt install python-pip python-opencv libzbar0 -y
sudo -H python -m pip install pyzbar

# Install Zoef ROS package
mkdir -p /home/zoef/zoef_ws/src
cd /home/zoef/zoef_ws/src
ln -s $ZOEF_SRC_DIR/zoef_ros_package .
ln -s $ZOEF_SRC_DIR/zoef_msgs .
cd ..
rosdep install -y --from-paths src/ --ignore-src --rosdistro melodic
catkin build
grep -qxF "source /home/zoef/zoef_ws/devel/setup.bash" /home/zoef/.bashrc || echo "source /home/zoef/zoef_ws/devel/setup.bash" >> /home/zoef/.bashrc
source /home/zoef/zoef_ws/devel/setup.bash

# Add systemd service to start ROS nodes
sudo rm /lib/systemd/system/zoef_ros.service
sudo ln -s $ZOEF_SRC_DIR/zoef_install_scripts/services/zoef_ros.service /lib/systemd/system/

sudo systemctl daemon-reload
sudo systemctl stop zoef_ros || /bin/true
sudo systemctl start zoef_ros
sudo systemctl enable zoef_ros
