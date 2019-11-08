#bin/bash

if [ ! -f /etc/ssid ]; then
    UNIQUE_ID=$(openssl rand -hex 3)
    ZOEF_SSID=Zoef_$(echo ${UNIQUE_ID^^})
    sudo bash -c 'echo '$ZOEF_SSID' > /etc/ssid'
fi

sudo service dnsmasq stop
sleep 15

iwgetid -r

if [ $? -eq 0 ]; then
    printf 'Skipping WiFi Connect\n'
else
    printf 'Starting WiFi Connect\n'
    sudo wifi-connect -o 8080 -p zoef_zoef -s `cat /etc/ssid`
    sudo service dnsmasq start
fi

