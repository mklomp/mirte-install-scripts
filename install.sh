#!/bin/bash

ZOEF_SRC_DIR=/usr/local/src/zoef

# Install dependencies
sudo apt install -y git curl binutils libusb-1.0-0

# Install arduino-cli
curl https://raw.githubusercontent.com/arduino/arduino-cli/master/install.sh | sudo BINDIR=/usr/local/bin sh
sudo chown -R zoef:zoef /home/zoef/.arduino15

# Install arduino avr support (for nano)
arduino-cli core update-index --additional-urls https://raw.githubusercontent.com/zoef-robot/stm32duino-raspberrypi/master/BoardManagerFiles/package_stm_index.json -v
arduino-cli core install arduino:avr

# Install STM32 support. Currently not supported by stm32duino (see https://github.com/stm32duino/Arduino_Core_STM32/issues/708), but there is already
# a community version (https://github.com/koendv/stm32duino-raspberrypi). TODO: go back to stm32duino as soon as it is merged into stm32duino.
# Currently the community version is broken as well due to a new xpack version. This will probably also mean that the stm32duino version might include this into their own.
arduino-cli core install STM32:stm32 --additional-urls https://raw.githubusercontent.com/zoef-robot/stm32duino-raspberrypi/master/BoardManagerFiles/package_stm_index.json -v
#arduino-cli core install STM32:stm32 --additional-urls https://github.com/stm32duino/BoardManagerFiles/raw/master/STM32/package_stm_index.json

# Fix for community STM32 (TODO: make version independant)
sed -i 's/dfu-util\.sh/dfu-util\/dfu-util/g' /home/zoef/.arduino15/packages/STM32/tools/STM32Tools/1.4.0/tools/linux/maple_upload
ln -s /home/zoef/.arduino15/packages/STM32/tools/STM32Tools/1.4.0/tools/linux/maple_upload /home/zoef/.arduino15/packages/STM32/tools/STM32Tools/1.4.0/tools/linux/maple_upload.sh

# Install libraries needed by FirmataExpress
arduino-cli lib install "Ultrasonic"
arduino-cli lib install "Stepper"
arduino-cli lib install "Servo"

# Install our own arduino libraries
ln -s $ZOEF_SRC_DIR/zoef-arduino-libraries/OpticalEncoder /home/zoef/Arduino/libraries

# Install Blink example code
mkdir /home/zoef/arduino_project/Blink
ln -s $ZOEF_SRC_DIR/zoef_arduino/Blink.ino /home/zoef/arduino_project/Blink

# Already build all versions so only upload is needed
sudo ./run.sh build FirmataExpress
sudo ./run.sh build_nano FirmataExpress
sudo ./run.sh build_nano_old FirmataExpress

# Add zoef to dialout
sudo adduser zoef dialout

# By default, armbian has ssh login for root enabled with password 1234.
# The password need to be set to zoef_zoef so users can use the
# Arduino IDE remotely. 
# TODO: when the Arduino IDE also supports ssh for non-root-users
# this has to be changed
echo -e "zoef_zoef\nzoef_zoef" | sudo passwd root

# Enable tuploading from remote IDE
ln -s $ZOEF_SRC_DIR/zoef_arduino/run-avrdude /usr/bin
sudo bash -c 'echo "zoef ALL = (root) NOPASSWD: /usr/local/bin/arduino-cli" >> /etc/sudoers'
