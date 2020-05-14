#!/bin/bash 

ZOEF_SRC_DIR=/usr/local/src/zoef

# Install wifi-connect
bash <(curl -L https://github.com/balena-io/wifi-connect/raw/master/scripts/raspbian-install.sh)
systemctl disable systemd-resolved
echo "nameserver 8.8.8.8" > /etc/resolv.conf
apt install -y dnsmasq
systemctl disable dnsmasq # will be started by wifi-connect
systemctl disable hostapd

# Added systemd service to account for fix: https://askubuntu.com/questions/472794/hostapd-error-nl80211-could-not-configure-driver-mode
sudo rm /lib/systemd/system/zoef_ap.service
sudo ln -s $ZOEF_SRC_DIR/zoef_install_scripts/services/zoef_ap.service /lib/systemd/system/

sudo systemctl daemon-reload
sudo systemctl stop zoef_ap || /bin/true
sudo systemctl start zoef_ap
sudo systemctl enable zoef_ap

# Generate wifi password (TODO: generate random password and put on NTFS)
if [ ! -f /etc/wifi_pwd ]; then
    sudo bash -c 'echo zoef_zoef > /etc/wifi_pwd'
fi
