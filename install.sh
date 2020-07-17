#!/bin/bash

ZOEF_SRC_DIR=/usr/local/src/zoef

# Install our own arduino libraries
ln -s /usr/local/src/zoef/zoef-arduino-libraries/OpticalEncoder /home/zoef/arduino_project/libraries

# Install singularity image
sudo apt install -y singularity-container
sudo rm -rf arduino_utils
sudo singularity build --sandbox arduino_utils Singularity
sudo ./run.sh build
sudo ./run.sh build_old
sudo ./run.sh build_stm32

# Add zoef to dialout
sudo adduser zoef dialout

# Temp fix to be able to upload to stm32 without root pwd (from user interface)
sudo bash -c 'echo "zoef ALL = (root) NOPASSWD: /usr/local/src/zoef/zoef_arduino/run.sh" >> /etc/sudoers'

# Enable usbmon
#echo usbmon | sudo tee -a /etc/modules
