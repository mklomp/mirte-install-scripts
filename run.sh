#!/bin/bash

sudo service zoef_ros stop || /bin/true

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

sudo service zoef_ros start || /bin/true
