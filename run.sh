#!/bin/bash

#TODO: script should have format ./run.sh build|upload] mcu_type arduino_folder
# with mcu_type and arduino_folder optional

# Check if ROS is running
ROS_RUNNING=`ps aux | grep [r]osmaster | wc -l`

# Stop ROS when uploading new code
if test "$1" == "upload" && [[ $ROS_RUNNING == "1" ]]
then
    echo "STOPPING ROS"
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
if test "$1" == "upload" && test "$2" == "Telemetrix4Arduino" && [[ $ROS_RUNNING == "1" ]]
then
   sudo service zoef_ros start
   echo "STARTING ROS"
fi
