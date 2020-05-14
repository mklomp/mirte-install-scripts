#!/bin/bash

ZOEF_SRC_DIR=/usr/local/src/zoef

iwgetid -r
if [ $? -eq 0 ]; then
    printf 'Skipping WiFi Connect\n'
    sudo $ZOEF_SRC_DIR/zoef_install_scripts/blink.sh $(hostname -I) &
else
    sudo service dnsmasq stop
    printf 'Starting WiFi Connect\n'
    UNIQUE_ID=$(cat /etc/hostname | cut -c6-11)
    sudo $ZOEF_SRC_DIR/zoef_install_scripts/blink.sh $UNIQUE_ID &
    sudo wifi-connect -o 8080 -p `cat /etc/wifi_pwd` -s `cat /etc/hostname` &
fi

# TODO: publish on possibly different networks for eth0 and wlan0
# Publish avahi (not using daemon since we publish two addresses)
avahi-publish-address -R zoef.local $(hostname -I | awk '{print $1}') &
avahi-publish-service `cat /etc/hostname` _zoef._tcp 80 &
sleep 10 #For some reason the hostname will only be set correctly after a sleep
avahi-set-host-name `cat /etc/hostname`
sleep infinity
