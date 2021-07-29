#!/bin/bash

#TODO: get this as a parameter
MIRTE_SRC_DIR=/usr/local/src/mirte

# There is a bug with Cmake in qemu for armhf:
# https://gitlab.kitware.com/cmake/cmake/-/issues/20568
# So we need to install a newer version of Cmake
# https://apt.kitware.com/
wget -O - https://apt.kitware.com/keys/kitware-archive-latest.asc 2>/dev/null | gpg --dearmor - | sudo tee /usr/share/keyrings/kitware-archive-keyring.gpg >/dev/null
echo 'deb [signed-by=/usr/share/keyrings/kitware-archive-keyring.gpg] https://apt.kitware.com/ubuntu/ focal main' | sudo tee /etc/apt/sources.list.d/kitware.list >/dev/null
sudo apt-get update
sudo rm /usr/share/keyrings/kitware-archive-keyring.gpg
sudo apt-get install kitware-archive-keyring
sudo apt-get install cmake-data=3.20.5-0kitware1ubuntu20.04.1
sudo apt-get install cmake=3.20.5-0kitware1ubuntu20.04.1

# Install ROS Noetic
sudo sh -c 'echo "deb http://ftp.tudelft.nl/ros/ubuntu $(lsb_release -sc) main" > /etc/apt/sources.list.d/ros-latest.list'
sudo apt-key adv --keyserver 'hkp://keyserver.ubuntu.com:80' --recv-key C1CF6E31E6BADE8868B172B4F42ED6FBAB17C654
sudo apt update
sudo apt install -y ros-noetic-ros-base python3-rosdep python3-rosinstall python3-rosinstall-generator python3-wstool build-essential python3-catkin-tools python3-osrf-pycommon
grep -qxF "source /opt/ros/noetic/setup.bash" /home/mirte/.bashrc || echo "source /opt/ros/noetic/setup.bash" >> /home/mirte/.bashrc
source /opt/ros/noetic/setup.bash
sudo rosdep init
rosdep update

# Install computer vision libraries
#TODO: make dependecies of ROS package
sudo apt install python3-pip python3-wheel python3-setuptools python3-opencv libzbar0 -y
sudo -H python3 -m pip install pyzbar

# Move custom settings to writabel filesystem
cp $MIRTE_SRC_DIR/mirte_ros_package/config/mirte_user_settings.yaml /home/mirte/.user_settings.yaml
rm $MIRTE_SRC_DIR/mirte_ros_package/config/mirte_user_settings.yaml
ln -s /home/mirte/.user_settings.yaml $MIRTE_SRC_DIR/mirte_ros_package/config/mirte_user_settings.yaml

# Install Mirte ROS package
mkdir -p /home/mirte/mirte_ws/src
cd /home/mirte/mirte_ws/src
ln -s $MIRTE_SRC_DIR/mirte_ros_package .
ln -s $MIRTE_SRC_DIR/mirte_msgs .
cd ..
rosdep install -y --from-paths src/ --ignore-src --rosdistro noetic
catkin build
grep -qxF "source /home/mirte/mirte_ws/devel/setup.bash" /home/mirte/.bashrc || echo "source /home/mirte/mirte_ws/devel/setup.bash" >> /home/mirte/.bashrc
source /home/mirte/mirte_ws/devel/setup.bash

# install missing python dependencies rosbridge
sudo apt install libffi-dev
sudo pip3 install twisted pyOpenSSL autobahn tornado pymongo pillow

# Add systemd service to start ROS nodes
sudo rm /lib/systemd/system/mirte_ros.service
sudo ln -s $MIRTE_SRC_DIR/mirte_install_scripts/services/mirte_ros.service /lib/systemd/system/

sudo systemctl daemon-reload
sudo systemctl stop mirte_ros || /bin/true
sudo systemctl start mirte_ros
sudo systemctl enable mirte_ros

# Install OLED dependencies
sudo apt install -y python3-bitstring libfreetype6-dev libjpeg-dev python3.8-dev
sudo -H python3.8 -m pip install pillow adafruit-circuitpython-ssd1306

# Install aio dependencies
sudo -H python3.8 -m pip install janus async-generator nest-asyncio
git clone https://github.com/locusrobotics/aiorospy.git
cd aiorospy/aiorospy
sudo -H python3.8 -m pip install .
cd ../..
rm -rf aiorospy
