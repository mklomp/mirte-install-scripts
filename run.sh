#!/bin/bash

echo 
if test -z $1  || test "$1" == "upload"
then
#   sudo singularity run --app upload --bind ino_project:/ino_project arduino_utils
    sudo singularity exec --bind ino_project:/ino_project arduino_utils/ /bin/bash -c "cd /ino_project && rm -rf .build && ino build -m nano328 && ino upload -m nano328"
fi
if test "$1" == "upload_old"
then
#   sudo singularity run --app upload_old --bind ino_project:/ino_project arduino_utils
    sudo singularity exec --bind ino_project:/ino_project arduino_utils/ /bin/bash -c "cd /ino_project && rm -rf .build && ino build -m nano328 && cp -r .build/nano328 .build/mini328 && ino upload -m mini328"
fi
if test "$1" == "build"
then
   sudo singularity run --app build --bind ino_project:/ino_project arduino_utils
fi
if test "$1" == "monitor"
then
   sudo singularity run --app monitor arduino_utils
fi

