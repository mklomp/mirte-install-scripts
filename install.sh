#!/bin/bash

# Install singularity image
sudo apt install -y singularity-container
sudo rm -rf arduino_utils
sudo singularity build --sandbox arduino_utils Singularity
sudo ./run.sh build
sudo ./run.sh build_old
sudo ./run.sh build_stm32

# Add zoef to dialout
sudo adduser zoef dialout

# Enable usbmon
#echo usbmon | sudo tee -a /etc/modules
