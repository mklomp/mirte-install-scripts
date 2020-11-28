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

# Install dependecnies to be able to run python3.8
sudo apt install -y python3.8 python3-pip python3-setuptools

# Install Zoef Interface
cd $ZOEF_SRC_DIR/web_interface
./install.sh

# Install Jupyter Notebook
cd $ZOEF_SRC_DIR/zoef_install_scripts
./install_jupyter_ros.sh

# Install telemetrix
cd $ZOEF_SRC_DIR/zoef_pymata
sudo -H python3.8 -m pip install .

# Install Telemtrix4Arduino project
cd $ZOEF_SRC_DIR/zoef_install_scripts
mkdir -p /home/zoef/Arduino/libraries
mkdir -p /home/zoef/arduino_project/Telemtrix4Arduino
ln -s $ZOEF_SRC_DIR/Telemetrix4Arduino /home/zoef/Arduino/libraries/Telemetrix4Arduino
ln -s $ZOEF_SRC_DIR/Telemetrix4Arduino/examples/Telemetrix4Arduino/Telemetrix4Arduino.ino /home/zoef/arduino_project/Telemetrix4Arduino

# Install arduino firmata upload script
cd $ZOEF_SRC_DIR/zoef_arduino
./install.sh

# Install Zoef ROS packages
cd $ZOEF_SRC_DIR/zoef_install_scripts
./install_ROS.sh

# Install Rust
#curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
#cd $ZOEF_SRC_DIR/
#git clone https://github.com/zoef-robot/wifi-connect.git
#cd wifi-connect
#cargo-build
