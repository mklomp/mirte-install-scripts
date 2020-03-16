#!/bin/bash

sudo service zoef_ros stop
echo 
if test -z $1  || test "$1" == "upload"
then
    sudo singularity run --app upload --bind arduino_project:/arduino_project arduino_utils
fi
if test "$1" == "upload_old"
then
    sudo singularity run --app upload_old --bind arduino_project:/arduino_project arduino_utils
fi
if test "$1" == "upload_stm32"
then
    sudo singularity run --app upload_stm32 --bind arduino_project:/arduino_project arduino_utils
fi

if test "$1" == "build"
then
   sudo singularity run --app build --bind ino_project:/ino_project arduino_utils
fi
#if test "$1" == "monitor"
#then
#   sudo singularity run --app monitor arduino_utils
#fi

sudo service zoef_ros start
