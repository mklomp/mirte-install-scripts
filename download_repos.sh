#!/bin/bash

# Install vcstool
sudo sh -c 'echo "deb http://packages.ros.org/ros/ubuntu $(lsb_release -sc) main" > /etc/apt/sources.list.d/ros-latest.list'
sudo apt-key adv --keyserver hkp://pool.sks-keyservers.net --recv-key 0xAB17C654
sudo apt-get update
sudo apt-get install -y python3-vcstool

# Download all Zoef repositories
git config --global credential.helper 'store --file /.my-credentials'
vcs import < repos.yaml --workers 1  #TODO: get yaml file as parameter
rm /.my-credentials
