#!/bin/bash

ZOEF_SRC_DIR=/usr/local/src/zoef

#TODO: find out why this is needed
mount -t proc none /proc

# Update
sudo apt update

# Add zoef user with sudo rights
#TODO: user without homedir (create homedir for user)
useradd -m -G sudo -s /bin/bash zoef
mkdir /home/zoef/workdir
echo -e "zoef_zoef\nzoef_zoef" | passwd zoef
passwd --expire zoef

# Disable ssh root login
sed -i 's/#PermitRootLogin yes/PermitRootLogin no/g' /etc/ssh/sshd_config

# Install vcstool
sudo sh -c 'echo "deb http://packages.ros.org/ros/ubuntu $(lsb_release -sc) main" > /etc/apt/sources.list.d/ros-latest.list'
sudo apt-key adv --keyserver hkp://pool.sks-keyservers.net --recv-key 0xAB17C654
sudo apt-get update
sudo apt-get install -y python3-vcstool

# Download all Zoef repositories
mkdir -p $ZOEF_SRC_DIR
cp repos.yaml $ZOEF_SRC_DIR
cd $ZOEF_SRC_DIR
git config --global credential.helper 'store --file /.my-credentials'
vcs import < repos.yaml --workers 1
rm /.my-credentials

# Install arduino firmata upload script
cd $ZOEF_SRC_DIR/zoef_arduino
./install.sh

# Install Zoef Interface
cd $ZOEF_SRC_DIR/web_interface
./install.sh

# Install Jupyter Notebook
cd $ZOEF_SRC_DIR/zoef_install_scripts
./install_jupyter_ros.sh

# Install pymata
cd $ZOEF_SRC_DIR/zoef_pymata
sudo python setup.py install

# Install Zoef ROS packages
cd $ZOEF_SRC_DIR/zoef_install_scripts
./install_ROS.sh

