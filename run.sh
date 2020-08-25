#!/bin/bash


if test "$1" == "upload"
then
    sudo service zoef_ros stop || /bin/true
fi

echo
if test -z $1
then
    sudo singularity run --app build --bind /home/zoef/arduino_project:/arduino_project --bind /usr/local/src/zoef:/usr/local/src/zoef arduino_utils FirmataExpress
    sudo singularity run --app upload --bind /home/zoef/arduino_project:/arduino_project --bind /usr/local/src/zoef:/usr/local/src/zoef arduino_utils FirmataExpress
else
    sudo singularity run --app $1 --bind /home/zoef/arduino_project:/arduino_project --bind /usr/local/src/zoef:/usr/local/src/zoef arduino_utils $2
fi

#if test "$1" == "monitor"
#then
#   sudo singularity run --app monitor arduino_utils
#fi

if test "$1" == "upload"
then
    if test "$2" == "FirmataExpress"
    then
        sudo service zoef_ros start || /bin/true
        echo "ROS is starting"
    else
        echo "ROS not started"
    fi
fi
