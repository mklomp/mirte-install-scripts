#!/bin/bash

ZOEF_SRC_DIR=/usr/local/src/zoef

# Create unique SSID
# This must be run every time on boot, since it should
# be generated on first boot (so not when generating
# the image in network_setup.sh)
if [ ! -f /etc/ssid ]; then
    UNIQUE_ID=$(openssl rand -hex 3)
    ZOEF_SSID=Zoef_$(echo ${UNIQUE_ID^^})
    sudo bash -c 'echo '$ZOEF_SSID' > /etc/hostname'
    sudo ln -s /etc/hostname /etc/ssid
fi

# wait until wifi connected?
NEXT_WAIT_TIME=0; until [ $NEXT_WAIT_TIME -eq 10 ] || [ `iwgetid -r` ]; do echo "wating for connection"; sleep 1; let "NEXT_WAIT_TIME=NEXT_WAIT_TIME+1"; done

iwgetid -r
if [ $? -eq 0 ]; then
    printf 'Skipping WiFi Connect\n'
    sudo $ZOEF_SRC_DIR/zoef_install_scripts/blink.sh $(hostname -I) &
else
    printf 'Starting WiFi Connect\n'
    # remove own connection from nm
    sudo rm -rf /etc/NetworkManager/system-connections/`cat /etc/hostname`*
    nmcli -t -f ALL dev wifi rescan
    sleep 15
    sudo wifi-connect -o 8080 -p `cat /etc/wifi_pwd` -s `cat /etc/hostname` &
    # set to pairwise to make sure avahi will work over wifi (TODO: or do we need to do this
    # with inotify to make sure this also works after connection fails and AP gett up again
    until [ -f /etc/NetworkManager/system-connections/`cat /etc/hostname` ]
    do
       sleep .1
       echo " wainting for network"
    done
    UNIQUE_ID=$(cat /etc/hostname | cut -c6-11)
    sudo $ZOEF_SRC_DIR/zoef_install_scripts/blink.sh $UNIQUE_ID &
    nmcli con modify `cat /etc/hostname` 802-11-wireless-security.proto rsn
    nmcli con modify `cat /etc/hostname` 802-11-wireless-security.group ccmp
    nmcli con modify `cat /etc/hostname` 802-11-wireless-security.pairwise ccmp
    nmcli con down `cat /etc/hostname`
    nmcli con up `cat /etc/hostname`
fi

# Publish avahi (not using daemon since we publish two addresses)
#TODO: publish-address whould be updated after one has changed from ap->wifi.
avahi-publish-address -R zoef.local $(hostname -I | awk '{print $1}') &
avahi-set-host-name `cat /etc/hostname`
avahi-publish-service `cat /etc/hostname` _zoef._tcp 80 &
avahi-publish-service `cat /etc/hostname` _arduino._tcp 80 &
sleep infinity
