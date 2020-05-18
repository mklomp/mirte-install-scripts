#!/bin/bash
set -e

ZOEF_SRC_DIR=/usr/local/src/zoef

# Create unique SSID
if [ ! -f /etc/ssid ]; then
    UNIQUE_ID=$(openssl rand -hex 3)
    ZOEF_SSID=Zoef_$(echo ${UNIQUE_ID^^})
    sudo bash -c 'echo '$ZOEF_SSID' > /etc/hostname'
    sudo ln -s /etc/hostname /etc/ssid
fi

# Add zoef user with sudo rights
#TODO: user without homedir (create homedir for user)
sudo useradd -m -G sudo -s /bin/bash zoef
mkdir /home/zoef/workdir
sudo chown zoef:zoef /home/zoef/workdir
echo -e "zoef_zoef\nzoef_zoef" | passwd zoef
mkdir -p $ZOEF_SRC_DIR
sudo chown zoef:zoef $ZOEF_SRC_DIR
