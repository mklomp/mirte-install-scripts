#!/bin/bash

#TODO: get this as a parameter
MIRTE_SRC_DIR=/usr/local/src/mirte

# Install ROS Noetic
sudo apt install software-properties-common -y
sudo add-apt-repository universe -y
sudo apt update && sudo apt install curl -y
sudo curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key -o /usr/share/keyrings/ros-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] http://packages.ros.org/ros2/ubuntu $(. /etc/os-release && echo $UBUNTU_CODENAME) main" | sudo tee /etc/apt/sources.list.d/ros2.list > /dev/null
sudo apt update
sudo apt upgrade -y
sudo apt install ros-humble-ros-base
sudo apt install ros-humble-xacro
sudo apt install ros-dev-tools
grep -qxF "source /opt/ros/humble/setup.bash" /home/mirte/.bashrc || echo "source /opt/ros/humble/setup.bash" >> /home/mirte/.bashrc
source /opt/ros/humble/setup.bash
sudo rosdep init
rosdep update

# Install computer vision libraries
#TODO: make dependecies of ROS package
sudo apt install -y python3-pip python3-wheel python3-setuptools python3-opencv libzbar0
sudo pip3 install pyzbar mergedeep

# Move custom settings to writabel filesystem
#cp $MIRTE_SRC_DIR/mirte-ros-packages/mirte_telemetrix/config/mirte_user_settings.yaml /home/mirte/.user_settings.yaml
#rm $MIRTE_SRC_DIR/mirte-ros-packages/mirte_telemetrix/config/mirte_user_settings.yaml
#ln -s /home/mirte/.user_settings.yaml $MIRTE_SRC_DIR/mirte-ros-packages/config/mirte_user_settings.yaml

# Install Mirte ROS package
mkdir -p /home/mirte/mirte_ws/src
cd /home/mirte/mirte_ws/src
ln -s $MIRTE_SRC_DIR/mirte-ros-packages .
cd ..
rosdep install -y --from-paths src/ --ignore-src --rosdistro humble
colcon build
grep -qxF "source /home/mirte/mirte_ws/install/setup.bash" /home/mirte/.bashrc || echo "source /home/mirte/mirte_ws/install/setup.bash" >> /home/mirte/.bashrc
source /home/mirte/mirte_ws/install/setup.bash

# install missing python dependencies rosbridge
#sudo apt install -y libffi-dev libjpeg-dev zlib1g-dev
#sudo pip3 install twisted pyOpenSSL autobahn tornado pymongo

# Add systemd service to start ROS nodes
sudo rm /lib/systemd/system/mirte-ros.service
sudo ln -s $MIRTE_SRC_DIR/mirte-install-scripts/services/mirte-ros.service /lib/systemd/system/

sudo systemctl daemon-reload
sudo systemctl stop mirte-ros || /bin/true
sudo systemctl start mirte-ros
sudo systemctl enable mirte-ros

sudo usermod -a -G video mirte
sudo adduser mirte dialout
python3 -m pip install telemetrix-rpi-pico

# Install OLED dependencies (adafruit dependecies often break, so explicityle set to versions)
sudo apt install -y python3-bitstring libfreetype6-dev libjpeg-dev zlib1g-dev fonts-dejavu
sudo pip3 install adafruit-circuitpython-busdevice==5.1.1 adafruit-circuitpython-framebuf==1.4.9 adafruit-circuitpython-typing==1.7.0 Adafruit-PlatformDetect==3.22.1
sudo pip3 install pillow adafruit-circuitpython-ssd1306==2.12.1
