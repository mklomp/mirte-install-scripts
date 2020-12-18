#!/bin/bash

function start_avahi {
    # Restart avahi-daemon, to clear all previous addresses and hosts
    service avahi-daemon restart && sleep 1

    # Publish avahi (not using daemon since we publish two addresses)
    avahi-publish-address -R zoef.local $(hostname -I | awk '{print $1}') &
    avahi-set-host-name `cat /etc/hostname`
    avahi-publish-service `cat /etc/hostname` _zoef._tcp 80 &
    avahi-publish-service `cat /etc/hostname` _arduino._tcp 80 &
}


# This function basically just starts wifi-connect
# only taking some limitations into account
function start_acces_point {
    # remove own connection from nm and killall
    rm -rf /etc/NetworkManager/system-connections/`cat /etc/hostname`*
    sudo killall -9 wifi-connect
    sudo killall -9 blink.sh
    echo "Killed all previous instances"

    # It takes some time for NetworkManager to find all
    # networks.
    nmcli con down `cat /etc/hostname`
    iw dev wlan0 scan | grep SSID
    sleep 25
    iw dev wlan0 scan | grep SSID
    nmcli device wifi list
    echo "Rescanned networks"

    # Start wifi-connect (this starts the AP, and uses dnsmasq
    # as DHCP server
    wifi-connect -o 8080 -p `cat /etc/wifi_pwd` -s `cat /etc/hostname` &

    # Wait until the AP is up
    until [ -f /etc/NetworkManager/system-connections/`cat /etc/hostname` ]
    do
       sleep .1
       echo " waiting for network"
    done

    # And modify the network in a way that avahi mdns packages will
    # get through
    nmcli con modify `cat /etc/hostname` 802-11-wireless-security.proto rsn
    nmcli con modify `cat /etc/hostname` 802-11-wireless-security.group ccmp
    nmcli con modify `cat /etc/hostname` 802-11-wireless-security.pairwise ccmp
    nmcli con down `cat /etc/hostname`
    nmcli con up `cat /etc/hostname`

    # Start all avahi addresses and services
    start_avahi

    # Blink ssid-ID
    UNIQUE_ID=$(cat /etc/hostname | cut -c6-11)
#    $ZOEF_SRC_DIR/zoef_install_scripts/blink.sh $UNIQUE_ID &
}

function check_connection {
   # Wait for a connection with a known ssid (timeout 10 seconds)
   nmcli device set wlan0 autoconnect yes
   TIMEOUT=25;
   NEXT_WAIT_TIME=0; until [ $NEXT_WAIT_TIME -eq $TIMEOUT ] || [ `iwgetid -r` ]; do echo "wating for connection"; sleep 1; let "NEXT_WAIT_TIME=NEXT_WAIT_TIME+1"; done

   # Get wifi connection if connected
   sudo iwgetid -r
   if [ $? -eq 0 ]; then
      printf 'Connected to wifi connection:', iwgetid -r,'\n'
      $ZOEF_SRC_DIR/zoef_install_scripts/blink.sh $(hostname -I) &
      start_avahi
   else
      printf 'No connection found, starting AP with wifi connect\n'
      start_acces_point

      # Restart the whole network process when connection did not take place
      while inotifywait -e modify /etc/NetworkManager/system-connections/`cat /etc/hostname`; do echo "hoi" ; done
      printf "Networkmanager settings changed, restarting wifi-connect\n"
      sleep 5 # Give wifi-connect the possibility to change the settings
      printf "And doing the next thing\n"
      check_connection
   fi
}


ZOEF_SRC_DIR=/usr/local/src/zoef

# TODO: do this the nmcli way
sudo bash -c 'echo "nameserver 8.8.8.8" > /etc/resolv.conf'

# Create unique SSID
# This must be run every time on boot, since it should
# be generated on first boot (so not when generating
# the image in network_setup.sh)
if [ ! -f /etc/ssid ]; then
    UNIQUE_ID=$(openssl rand -hex 3)
    ZOEF_SSID=Zoef_$(echo ${UNIQUE_ID^^})
    sudo bash -c 'echo '$ZOEF_SSID' > /etc/hostname'
    sudo ln -s /etc/hostname /etc/ssid
    # And add them to the hosts file
    sudo bash -c 'echo '$ZOEF_SSID' > /etc/hosts'
    sudo bash -c 'echo "zoef" > /etc/hosts'
fi

check_connection

# This should run forever, otherwise systemd will shut it down
sleep infinity
