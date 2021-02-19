#!/bin/bash

#TODO: script should have format ./run.sh [build|upload] mcu_type arduino_folder
# with mcu_type and arduino_folder optional

# Stop ROS when uploading new code
if [[ $1 == "upload"* ]]
then
    sudo service zoef_ros stop || /bin/true
fi

# Different build scripts
if test "$1" == "build"
then
   arduino-cli -v compile --fqbn STM32:stm32:GenF1:pnum=BLACKPILL_F103C8,upload_method=dfu2Method,xserial=generic,usb=CDCgen,xusb=FS,opt=osstd,rtlib=nano /home/zoef/arduino_project/$2
fi
if test "$1" == "build_nano"
then
   arduino-cli -v compile --fqbn arduino:avr:nano:cpu=atmega328 /home/zoef/arduino_project/$2
fi
if test "$1" == "build_nano_old"
then
   arduino-cli -v compile --fqbn arduino:avr:nano:cpu=atmega328old /home/zoef/arduino_project/$2
fi

# Different upload scripts
if test "$1" == "upload"
then
   sudo arduino-cli -v upload -p /dev/ttyACM0 --fqbn STM32:stm32:GenF1:pnum=BLACKPILL_F103C8,upload_method=dfu2Method,xserial=generic,usb=CDCgen,xusb=FS,opt=osstd,rtlib=nano /home/zoef/arduino_project/$2
fi
if test "$1" == "upload_nano"
then
   sudo arduino-cli -v upload -p /dev/ttyUSB0 --fqbn arduino:avr:nano:cpu=atmega328 /home/zoef/arduino_project/$2
fi
if test "$1" == "upload_nano_old"
then
   sudo arduino-cli -v upload -p /dev/ttyUSB0 --fqbn arduino:avr:nano:cpu=atmega328old /home/zoef/arduino_project/$2
fi


# Start ROS again
if [[ $1 == "upload"* ]]
then
    if test "$2" == "Telemetrix4Arduino"
    then
        sudo service zoef_ros start || /bin/true
        echo "ROS is starting"
    else
        echo "ROS not started"
    fi
fi
