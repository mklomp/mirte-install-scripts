#!/bin/bash

ZOEF_SRC_DIR=/usr/local/src/zoef

if [ ! -f /etc/NetworkManager/system-connections/ZOEF_AP_CON ]; then
   # Set my own network connection since the one from fwifi-connect takes long to connect
   # AND the avahi mdns packets do not get though
   # Basically wifi-connect is now only used for the selection of the network. dnsmaqs ad dhcp
   # server is also not used anymore.
   # These settings are from: http://variwiki.com/index.php?title=Wifi_NetworkManager#Creating_WiFi_AP
   nmcli con add type wifi ifname wlan0 mode ap con-name ZOEF_AP_CON ssid Zoef
   nmcli con modify ZOEF_AP_CON 802-11-wireless.band bg
   nmcli con modify ZOEF_AP_CON 802-11-wireless.channel 1
   nmcli con modify ZOEF_AP_CON 802-11-wireless-security.key-mgmt wpa-psk
   nmcli con modify ZOEF_AP_CON 802-11-wireless-security.proto rsn
   nmcli con modify ZOEF_AP_CON 802-11-wireless-security.group ccmp
   nmcli con modify ZOEF_AP_CON 802-11-wireless-security.pairwise ccmp
   nmcli con modify ZOEF_AP_CON 802-11-wireless-security.psk 11223344
   nmcli con modify ZOEF_AP_CON ipv4.method shared
   nmcli con modify ZOEF_AP_CON ipv4.addr 192.168.42.1/24
fi

iwgetid -r
if [ $? -eq 0 ]; then
    printf 'Skipping WiFi Connect\n'
    sudo $ZOEF_SRC_DIR/zoef_install_scripts/blink.sh $(hostname -I) &
else
    sudo service dnsmasq start # To make sure that wifi-connect will not start it as well
    printf 'Starting WiFi Connect\n'
    UNIQUE_ID=$(cat /etc/hostname | cut -c6-11)
    sudo $ZOEF_SRC_DIR/zoef_install_scripts/blink.sh $UNIQUE_ID &
    sudo wifi-connect -o 8080 -p `cat /etc/wifi_pwd` -s `cat /etc/hostname` &
    sleep 10 #otherwise dnsmaq is not started yet
    sudo service dnsmasq stop # nm does not need a dhcp/dns server
    nmcli con modify ZOEF_AP_CON 802-11-wireless-security.psk `cat /etc/wifi_pwd`
    nmcli con modify ZOEF_AP_CON ssid `cat /etc/hostname`
    nmcli con up ZOEF_AP_CON
    #TODO: figure out if wifi-connect was unable to connst, we need to do this again.....
fi

# TODO: publish on possibly different networks for eth0 and wlan0
# Publish avahi (not using daemon since we publish two addresses)
avahi-publish-address -R zoef.local $(hostname -I | awk '{print $1}') &
avahi-publish-service `cat /etc/hostname` _zoef._tcp 80 &
avahi-publish-service `cat /etc/hostname` _arduino._tcp 80 &
sleep 10 #For some reason the hostname will only be set correctly after a sleep
avahi-set-host-name `cat /etc/hostname`
sleep infinity
