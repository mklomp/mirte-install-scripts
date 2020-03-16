#!/bin/bash

# Install FirmataPlus
sudo apt install -y wget unzip git
rm -rf ./arduino_project
mkdir -p ./arduino_project/FirmataPlusDue
cd ./arduino_project/FirmataPlusDue
wget https://github.com/MrYsLab/pymata-aio/raw/master/FirmataPlus/libraries.zip
unzip libraries.zip
rm -rf libraries.zip
cd libraries
git clone https://gitlab.tudelft.nl/rcj_zoef/zoef_firmata
cd zoef_firmata
git checkout --track origin/firmata-stm32
cd ..
mv zoef_firmata FirmataPlusDue
cd ..
cp libraries/FirmataPlusDue/examples/FirmataPlusDue/FirmataPlusDue.ino .
cp libraries/FirmataPlusDue/libraries/* libraries/ -R
cd ../..

# Install singularity image
# TODO: change Singularity file to install lib23z1 when on 64 bit machine
sudo apt install -y singularity-container
sudo rm -rf arduino_utils
sudo singularity build --sandbox arduino_utils Singularity

# Enable usbmon
#echo usbmon | sudo tee -a /etc/modules
