#!/bin/bash

#TODO: get this as a parameter
ZOEF_SRC_DIR=/usr/local/src/zoef


# We need to install a newer version of Cmake in order to run this from qemu
# https://gitlab.kitware.com/cmake/cmake/-/issues/20568
export CFLAGS="-D_FILE_OFFSET_BITS=64"
export CXXFLAGS="-D_FILE_OFFSET_BITS=64"
sudo apt remove -y --purge cmake
hash -r
sudo apt install build-essential libssl-dev
wget https://github.com/Kitware/CMake/releases/download/v3.20.2/cmake-3.20.2.tar.gz
tar -zxvf cmake-3.20.2.tar.gz
cd cmake-3.20.2
./bootstrap
make
sudo make install


# Install ROS Noetic
sudo sh -c 'echo "deb http://ftp.tudelft.nl/ros/ubuntu $(lsb_release -sc) main" > /etc/apt/sources.list.d/ros-latest.list'
sudo apt-key adv --keyserver 'hkp://keyserver.ubuntu.com:80' --recv-key C1CF6E31E6BADE8868B172B4F42ED6FBAB17C654
sudo apt update
sudo apt install -y ros-noetic-ros-base python3-rosdep python3-rosinstall python3-rosinstall-generator python3-wstool build-essential python3-catkin-tools python3-osrf-pycommon
grep -qxF "source /opt/ros/noetic/setup.bash" /home/zoef/.bashrc || echo "source /opt/ros/noetic/setup.bash" >> /home/zoef/.bashrc
source /opt/ros/noetic/setup.bash
sudo rosdep init
rosdep update

# Install computer vision libraries
#TODO: make dependecies of ROS package
sudo apt install python3-pip python3-wheel python3-setuptools python3-opencv libzbar0 -y
sudo -H python3 -m pip install pyzbar

# Move custom settings to writabel filesystem
cp $ZOEF_SRC_DIR/zoef_ros_package/config/zoef_user_settings.yaml /home/zoef/.user_settings.yaml
rm $ZOEF_SRC_DIR/zoef_ros_package/config/zoef_user_settings.yaml
ln -s /home/zoef/.user_settings.yaml $ZOEF_SRC_DIR/zoef_ros_package/config/zoef_user_settings.yaml

# Install Zoef ROS package
mkdir -p /home/zoef/zoef_ws/src
cd /home/zoef/zoef_ws/src
ln -s $ZOEF_SRC_DIR/zoef_ros_package .
ln -s $ZOEF_SRC_DIR/zoef_msgs .
cd ..
rosdep install -y --from-paths src/ --ignore-src --rosdistro noetic
catkin build
grep -qxF "source /home/zoef/zoef_ws/devel/setup.bash" /home/zoef/.bashrc || echo "source /home/zoef/zoef_ws/devel/setup.bash" >> /home/zoef/.bashrc
source /home/zoef/zoef_ws/devel/setup.bash

# install missing python dependencies rosbridge
sudo apt install libffi-dev
sudo pip3 install twisted pyOpenSSL autobahn tornado pymongo pillow

# Add systemd service to start ROS nodes
sudo rm /lib/systemd/system/zoef_ros.service
sudo ln -s $ZOEF_SRC_DIR/zoef_install_scripts/services/zoef_ros.service /lib/systemd/system/

sudo systemctl daemon-reload
sudo systemctl stop zoef_ros || /bin/true
sudo systemctl start zoef_ros
sudo systemctl enable zoef_ros

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
