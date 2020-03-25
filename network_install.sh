#!/bin/bash 

# Install wifi-connect
bash <(curl -L https://github.com/balena-io/wifi-connect/raw/master/scripts/raspbian-install.sh)
systemctl disable systemd-resolved
echo "nameserver 8.8.8.8" > /etc/resolv.conf
apt install -y dnsmasq
systemctl disable dnsmasq # will be enabled by wifi-connect
systemctl disable hostapd

# Added systemd service to account for fix: https://askubuntu.com/questions/472794/hostapd-error-nl80211-could-not-configure-driver-mode
sudo rm /lib/systemd/system/zoef_ap.service
sudo ln -s ./services/zoef_ap.service /lib/systemd/system/

sudo systemctl daemon-reload
sudo systemctl stop zoef_ap || /bin/true
sudo systemctl start zoef_ap
sudo systemctl enable zoef_ap

# Add avahi daemon to enable http://zoef.local
sudo apt-get install -y avahi-daemon
echo "zoef" > /etc/hostname
