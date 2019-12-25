#!/bin/bash

echo 
if test -z $1  || test "$1" == "upload"
then
   sudo singularity run --app upload --bind ino_project:/ino_project arduino_utils
fi
if test "$1" == "build"
then
   sudo singularity run --app build --bind ino_project:/ino_project arduino_utils
fi
if test "$1" == "monitor"
then
   sudo singularity run --app monitor arduino_utils
fi

