#!/bin/bash
# Or should we use https://docs.armbian.com/Developer-Guide_User-Configurations/#user-provided-image-customization-script

mount -t proc none /proc

# Save git credentials
git config --global credential.helper 'store --file ~/.my-credentials'

# Update
sudo apt update

# Install install scripts
sudo apt install -y git
cd ~
git clone https://gitlab.tudelft.nl/rcj_zoef/zoef_install_scripts.git

# Install arduino firmata upload script
cd ~
git clone https://gitlab.tudelft.nl/rcj_zoef/zoef_arduino.git
cd zoef_arduino
cp Singularity Singularity.orig
sed -i 's/%post/%files\n    \/usr\/bin\/qemu-arm-static \/usr\/bin\/\n\n%post/g' Singularity  #TODO: only when not already there
./install.sh
mv Singularity.orig Singularity
./run.sh

# Make working directory for user scripts (TODO: maybe cretae own user?)
mkdir ~/workdir

# Install Zoef Interface
sudo apt install -y singularity-container
cd ~
git clone https://gitlab.tudelft.nl/rcj_zoef/web_interface.git
cd web_interface
cp Singularity Singularity.orig
sed -i 's/From: ubuntu:bionic/From: arm32v7\/ubuntu:bionic/g' Singularity
sed -i 's/%files/%files\n    \/usr\/bin\/qemu-arm-static \/usr\/bin\//g' Singularity
sudo rm -rf zoef_web_interface
grep -qxF "export PYTHONPATH=$PYTHONPATH:/home/zoef/web_interface/python" ~/.bashrc || echo "export PYTHONPATH=$PYTHONPATH:/home/zoef/web_interface/python" >> ~/.bashrc
sudo cp /home/zoef/web_interface/python/linetrace.py /home/zoef/workdir

./run_singularity.sh build_dev
mv Singularity.orig Singularity

# Add systemd service to start ROS nodes
# NOTE: starting singularity image form ssystemd has some issues (https://github.com/sylabs/singularity/issues/1600)
sudo rm /lib/systemd/system/zoef_web_interface.service
sudo bash -c "echo '[Unit]' > /lib/systemd/system/zoef_web_interface.service"
sudo bash -c "echo 'Description=Zoef Web Interface' >> /lib/systemd/system/zoef_web_interface.service"
sudo bash -c "echo 'After=network.target' >> /lib/systemd/system/zoef_web_interface.service"
sudo bash -c "echo 'After=ssh.service' >> /lib/systemd/system/zoef_web_interface.service"
sudo bash -c "echo 'After=network-online.target' >> /lib/systemd/system/zoef_web_interface.service"
sudo bash -c "echo '' >> /lib/systemd/system/zoef_web_interface.service"
sudo bash -c "echo '[Service]' >> /lib/systemd/system/zoef_web_interface.service"
sudo bash -c "echo 'ExecStart=/bin/bash -c \"nodejs /home/zoef/web_interface/web-shell.js & cd /home/zoef/web_interface/ && singularity run -B app:/app/my_app -B /home/zoef/workdir:/workdir zoef_web_interface 2>&1 | tee\"' >> /lib/systemd/system/zoef_web_interface.service"
sudo bash -c "echo '' >> /lib/systemd/system/zoef_web_interface.service"
sudo bash -c "echo '[Install]' >> /lib/systemd/system/zoef_web_interface.service"
sudo bash -c "echo 'WantedBy=multi-user.target' >> /lib/systemd/system/zoef_web_interface.service"

sudo systemctl daemon-reload
sudo systemctl stop zoef_web_interface || /bin/true
sudo systemctl start zoef_web_interface
sudo systemctl enable zoef_web_interface

# Install Jupyter Notebook
cd ~/zoef_install_scripts
su zoef bash -c "./install_jupyter_ros.sh"

# first install NPM, then ROS due to bug (https://github.com/ros/rosdistro/issues/19845)
sudo apt purge -y ros-*
sudo apt autoremove -y
sudo apt install nodejs npm -y
sudo npm install express express-ws node-pty

# Install ROS Melodic
sudo sh -c 'echo "deb http://packages.ros.org/ros/ubuntu $(lsb_release -sc) main" > /etc/apt/sources.list.d/ros-latest.list'
sudo apt-key adv --keyserver 'hkp://keyserver.ubuntu.com:80' --recv-key C1CF6E31E6BADE8868B172B4F42ED6FBAB17C654
sudo apt update
sudo apt install -y ros-melodic-ros-base python-rosinstall python-rosinstall-generator python-wstool build-essential python-catkin-tools
sudo rosdep init
rosdep update
grep -qxF "source /opt/ros/melodic/setup.bash" ~/.bashrc || echo "source /opt/ros/melodic/setup.bash" >> ~/.bashrc
source /opt/ros/melodic/setup.bash

# Install pymata and allow usage of usb device
cd ~
git clone https://gitlab.tudelft.nl/rcj_zoef/zoef_pymata
cd ~/zoef_pymata
sudo python setup.py install

# Install computer vision libraries
sudo apt install python-opencv libzbar0 -y
sudo -H python -m pip install pyzbar

# Install Zoef ROS package (TODO: create rosinstall/rosdep)
mkdir -p ~/zoef_ws/src
cd ~/zoef_ws/src
git clone https://gitlab.tudelft.nl/rcj_zoef/zoef_ros_package.git
git clone https://gitlab.tudelft.nl/rcj_zoef/zoef_msgs.git
cd ..
rosdep install -y --from-paths src/ --ignore-src --rosdistro melodic
catkin build
grep -qxF "source /home/zoef/zoef_ws/devel/setup.bash" ~/.bashrc || echo "source /home/zoef/zoef_ws/devel/setup.bash" >> ~/.bashrc
source /home/zoef/zoef_ws/devel/setup.bash

# Add zoef to dialout
sudo adduser zoef dialout

# Add systemd service to start ROS nodes
sudo rm /lib/systemd/system/zoef_ros.service
sudo bash -c "echo '[Unit]' > /lib/systemd/system/zoef_ros.service"
sudo bash -c "echo 'Description=Zoef ROS' >> /lib/systemd/system/zoef_ros.service"
sudo bash -c "echo 'After=network.target' >> /lib/systemd/system/zoef_ros.service"
sudo bash -c "echo 'After=ssh.service' >> /lib/systemd/system/zoef_ros.service"
sudo bash -c "echo 'After=network-online.target' >> /lib/systemd/system/zoef_ros.service"
sudo bash -c "echo '' >> /lib/systemd/system/zoef_ros.service"
sudo bash -c "echo '[Service]' >> /lib/systemd/system/zoef_ros.service"
sudo bash -c "echo 'ExecStart=/bin/bash -c \"source /home/zoef/zoef_ws/devel/setup.bash && roslaunch zoef_ros_package hw_control.launch\"' >> /lib/systemd/system/zoef_ros.service"
sudo bash -c "echo '' >> /lib/systemd/system/zoef_ros.service"
sudo bash -c "echo '[Install]' >> /lib/systemd/system/zoef_ros.service"
sudo bash -c "echo 'WantedBy=multi-user.target' >> /lib/systemd/system/zoef_ros.service"

sudo systemctl daemon-reload
sudo systemctl stop zoef_ros || /bin/true
sudo systemctl start zoef_ros
sudo systemctl enable zoef_ros

# Remove git credentials
rm ~/.my-credentials
