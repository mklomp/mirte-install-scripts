#!/bin/bash

# Install FirmataPlus
sudo apt install -y wget unzip git
mkdir ./ino_project
cd ./ino_project
wget https://github.com/MrYsLab/pymata-aio/raw/master/FirmataPlus/libraries.zip
unzip libraries.zip
mv libraries lib
rm -rf libraries.zip
mkdir src

# Replace default FirmataPlus with our own version
cd lib
git clone https://gitlab.tudelft.nl/rcj_zoef/zoef_firmata
cd ..
cp ./lib/zoef_firmata/examples/FirmataPlus/FirmataPlus.ino ./src
mv ./lib/zoef_firmata/libraries/* ./lib
cd lib
rm -rf FirmataPlus
mv zoef_firmata FirmataPlus
cd ../..

# Install singularity image 
sudo apt install -y singularity-container
rm -rf arduino_utils
sudo singularity build --sandbox arduino_utils Singularity

# Enable usbmon
echo usbmon | sudo tee -a /etc/modules
