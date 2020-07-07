#!/bin/bash

sudo service zoef_ros stop || /bin/true

echo 
if test -z $1
then
    sudo singularity run --app build --bind /home/zoef/arduino_project:/arduino_project --bind /usr/local/src/zoef:/usr/local/src/zoef arduino_utils
    sudo singularity run --app upload --bind /home/zoef/arduino_project:/arduino_project --bind /usr/local/src/zoef:/usr/local/src/zoef arduino_utils
fi

if test "$1" == "build"
then
    sudo singularity run --app build --bind /home/zoef/arduino_project:/arduino_project --bind /usr/local/src/zoef:/usr/local/src/zoef arduino_utils
fi
if test "$1" == "upload"
then
    sudo singularity run --app upload --bind /home/zoef/arduino_project:/arduino_project --bind /usr/local/src/zoef:/usr/local/src/zoef arduino_utils
fi

if test "$1" == "build_old"
then
    sudo singularity run --app build_old --bind /home/zoef/arduino_project:/arduino_project --bind /usr/local/src/zoef:/usr/local/src/zoef arduino_utils
fi
if test "$1" == "upload_old"
then
    sudo singularity run --app upload_old --bind /home/zoef/arduino_project:/arduino_project --bind /usr/local/src/zoef:/usr/local/src/zoef arduino_utils
fi

if test "$1" == "build_stm32"
then
    sudo singularity run --app build_stm32 --bind /home/zoef/arduino_project:/arduino_project --bind /usr/local/src/zoef:/usr/local/src/zoef arduino_utils
fi
if test "$1" == "upload_stm32"
then
    sudo singularity run --app upload_stm32 --bind /home/zoef/arduino_project:/arduino_project --bind /usr/local/src/zoef:/usr/local/src/zoef  /usr/local/src/zoef/zoef_arduino/arduino_utils
fi

#if test "$1" == "monitor"
#then
#   sudo singularity run --app monitor arduino_utils
#fi

sudo service zoef_ros start || /bin/true
