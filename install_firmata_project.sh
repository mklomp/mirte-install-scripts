#!/bin/bash

ZOEF_SRC_DIR=/usr/local/src/zoef

# Install FirmataPlus
sudo apt install -y wget unzip git
mkdir -p /home/zoef/arduino_project/FirmataPlusDue
cd /home/zoef/arduino_project/FirmataPlusDue
wget https://github.com/MrYsLab/pymata-aio/raw/master/FirmataPlus/libraries.zip
unzip libraries.zip
rm -rf libraries.zip
ln -s $ZOEF_SRC_DIR/zoef_firmata libraries/FirmataPlusDue
ln -s $ZOEF_SRC_DIR/zoef_firmata/libraries/OpticalEncoder libraries/
ln -s $ZOEF_SRC_DIR/zoef_firmata/examples/Firmata*/Firmata*.ino ./FirmataPlusDue.ino
