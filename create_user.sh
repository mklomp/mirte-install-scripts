#!/bin/bash
set -e

ZOEF_SRC_DIR=/usr/local/src/zoef

# Add zoef user with sudo rights
#TODO: user without homedir (create homedir for user)
sudo useradd -m -G sudo,audio -s /bin/bash zoef
mkdir /home/zoef/workdir
sudo chown zoef:zoef /home/zoef/workdir
echo -e "zoef_zoef\nzoef_zoef" | passwd zoef
mkdir -p $ZOEF_SRC_DIR
sudo chown zoef:zoef $ZOEF_SRC_DIR
