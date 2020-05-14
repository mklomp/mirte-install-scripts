#!/bin/bash

# Install vcstool
sudo sh -c 'echo "deb http://ftp.tudelft.nl/ros/ubuntu $(lsb_release -sc) main" > /etc/apt/sources.list.d/ros-latest.list'
curl -sSL 'http://keyserver.ubuntu.com/pks/lookup?op=get&search=0xC1CF6E31E6BADE8868B172B4F42ED6FBAB17C654' | sudo apt-key add -
sudo apt-get update
sudo apt-get install -y python3-vcstool

# Download all Zoef repositories
git config --global credential.helper 'store --file ~/.my-credentials'
vcs import < repos.yaml --workers 1  #TODO: get yaml file as parameter
rm ~/.my-credentials

# TODO: set remote to gitlab when checkout from local
