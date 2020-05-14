#!/bin/bash
set -ex

ZOEF_SRC_DIR=/usr/local/src/zoef

# Update
sudo apt update

# Install locales
sudo apt install -y locales
sudo locale-gen "nl_NL.UTF-8"
sudo locale-gen "en_US.UTF-8"
sudo update-locale LC_ALL=en_US.UTF-8 LANGUAGE=en_US.UTF-8

# Install vcstool
cp repos.yaml $ZOEF_SRC_DIR
cp download_repos.sh $ZOEF_SRC_DIR
cd $ZOEF_SRC_DIR
./download_repos.sh

# Install Zoef Interface
cd $ZOEF_SRC_DIR/web_interface
./install.sh

# Install Jupyter Notebook
cd $ZOEF_SRC_DIR/zoef_install_scripts
./install_jupyter_ros.sh

# Install pymata
cd $ZOEF_SRC_DIR/zoef_pymata
sudo apt install -y python-setuptools
sudo python setup.py install

# Install Firmata project
cd $ZOEF_SRC_DIR/zoef_install_scripts
./install_firmata_project.sh

# Install arduino firmata upload script
cd $ZOEF_SRC_DIR/zoef_arduino
./install.sh

# Install Zoef ROS packages
cd $ZOEF_SRC_DIR/zoef_install_scripts
./install_ROS.sh


