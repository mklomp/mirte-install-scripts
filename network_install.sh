#!/bin/bash 

ZOEF_SRC_DIR=/usr/local/src/zoef

# Make sure there are no conflicting hcdp-servers
sudo apt install -y dnsmasq-base
systemctl disable hostapd

# Fix for bug in systemd-resolved
# (https://askubuntu.com/questions/973017/wrong-nameserver-set-by-resolvconf-and-networkmanager)
# For the installation we need 8.8.8.8, but linking will be done in network_setup.sh
sudo rm -rf /etc/resolv.conf
sudo bash -c 'echo "nameserver 8.8.8.8" > /etc/resolv.conf'

# Let netplan use NM (which is used by wifi-connect)
sudo apt install -y network-manager
sudo echo "   renderer: NetworkManager" >> /etc/netplan/50-cloud-init.yaml

# Install wifi-connect
wget https://github.com/balena-io/wifi-connect/raw/master/scripts/raspbian-install.sh
chmod +x raspbian-install.sh
./raspbian-install.sh -y
rm raspbian-install.sh

# Added systemd service to account for fix: https://askubuntu.com/questions/472794/hostapd-error-nl80211-could-not-configure-driver-mode
sudo rm /lib/systemd/system/zoef_ap.service
sudo ln -s $ZOEF_SRC_DIR/zoef_install_scripts/services/zoef_ap.service /lib/systemd/system/

sudo systemctl daemon-reload
sudo systemctl stop zoef_ap || /bin/true
sudo systemctl start zoef_ap
sudo systemctl enable zoef_ap

# Install avahi
sudo apt install -y libnss-mdns
sudo apt install -y avahi-utils avahi-daemon
sudo apt install -y avahi-utils avahi-daemon # NOTE: Twice, since regular apt installation on armbian fails (https://forum.armbian.com/topic/10204-cant-install-avahi-on-armbian-while-building-custom-image/)

# Disable lo interface for avahi
sed -i 's/#deny-interfaces=eth1/deny-interfaces=lo/g' /etc/avahi/avahi-daemon.conf

# Install dependecies needed for setup script
sudo apt install -y inotify-tools wireless-tools

# Disable ssh root login
sed -i 's/#PermitRootLogin yes/PermitRootLogin no/g' /etc/ssh/sshd_config

# Generate wifi password (TODO: generate random password and put on NTFS)
if [ ! -f /etc/wifi_pwd ]; then
    sudo bash -c 'echo zoef_zoef > /etc/wifi_pwd'
fi

# Allow wifi_pwd to be modified using the web interface
sudo chmod 777 /etc/wifi_pwd
