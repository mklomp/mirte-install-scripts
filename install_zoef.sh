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
mkdir -p $ZOEF_SRC_DIR
cp repos.yaml $ZOEF_SRC_DIR
cp download_repos.sh $ZOEF_SRC_DIR
cd $ZOEF_SRC_DIR
./download_repos.sh

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
apt install -y python-setuptools
sudo python setup.py install

# Install Zoef ROS packages
cd $ZOEF_SRC_DIR/zoef_install_scripts
./install_ROS.sh

