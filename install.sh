#!/bin/bash

ZOEF_SRC_DIR=/usr/local/src/zoef

# Install our own arduino libraries
ln -s $ZOEF_SRC_DIR/zoef-arduino-libraries/OpticalEncoder /home/zoef/arduino_project/FirmataExpress/libraries

# Install Blink example code
mkdir /home/zoef/arduino_project/Blink
ln -s $ZOEF_SRC_DIR/zoef_arduino/Blink.ino /home/zoef/arduino_project/Blink

# Install singularity image
sudo apt install -y singularity-container
sudo rm -rf arduino_utils
sudo singularity build --sandbox arduino_utils Singularity
sudo ./run.sh build FirmataExpress
sudo ./run.sh build_nano FirmataExpress
sudo ./run.sh build_nano_old FirmataExpress

# Add zoef to dialout
sudo adduser zoef dialout

# Temp fix to be able to upload to stm32 without root pwd (from user interface)
sudo bash -c 'echo "zoef ALL = (root) NOPASSWD: /usr/local/src/zoef/zoef_arduino/run.sh" >> /etc/sudoers'

# Enable usbmon
#echo usbmon | sudo tee -a /etc/modules

# By default, armbian has ssh login for root enabled with password 1234.
# The password need to be set to zoef_zoef so users can use the
# Arduino IDE remotely. 
# TODO: when the Arduino IDE also supports ssh for non-root-users
# this has to be changed
echo -e "zoef_zoef\nzoef_zoef" | sudo passwd root

