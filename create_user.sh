#!/bin/bash
set -e

MIRTE_SRC_DIR=/usr/local/src/mirte

# Add mirte user with sudo rights
#TODO: user without homedir (create homedir for user)
sudo useradd -m -G sudo,audio -s /bin/bash mirte
sudo mkdir /home/mirte/workdir
sudo chown mirte:mirte /home/mirte/workdir
echo -e "mirte_mirte\nmirte_mirte" | sudo passwd mirte
sudo mkdir -p $MIRTE_SRC_DIR
sudo chown mirte:mirte $MIRTE_SRC_DIR
