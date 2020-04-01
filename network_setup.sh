#bin/bash

ZOEF_SRC_DIR=/usr/local/src/zoef

if [ ! -f /etc/ssid ]; then
    UNIQUE_ID=$(openssl rand -hex 3)
    ZOEF_SSID=Zoef_$(echo ${UNIQUE_ID^^})
    sudo bash -c 'echo '$ZOEF_SSID' > /etc/ssid'
else
    UNIQUE_ID=$(cat /etc/ssid | cut -c6-11)
fi

if [ ! -f /etc/wifi_pwd ]; then
    sudo bash -c 'echo zoef_zoef > /etc/wifi_pwd'
fi

sudo service dnsmasq stop
sleep 15

iwgetid -r
if [ $? -eq 0 ]; then
    printf 'Skipping WiFi Connect\n'
    sudo $ZOEF_SRC_DIR/zoef_install_scripts/blink.sh $(hostname -I)
else
    printf 'Starting WiFi Connect\n'
    sudo $ZOEF_SRC_DIR/zoef_install_scripts/blink.sh $UNIQUE_ID > /home/zoef/blink.log &
    sudo wifi-connect -o 8080 -p `cat /etc/wifi_pwd` -s `cat /etc/ssid`
    sudo service dnsmasq start
fi
