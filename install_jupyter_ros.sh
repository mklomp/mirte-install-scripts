#!/bin/bash

# install basic python tools
sudo apt install -y python2.7 python-virtualenv python-dev git

# create and activate virtualenv
cd ~
python -m virtualenv jupyter
source ~/jupyter/bin/activate

# install jupyros
#pip install jupyter bqplot pyyaml ipywidgets
#pip install jupyros
#jupyter nbextension enable --py --sys-prefix jupyros
#deactivate

# TEMP: download examples
#git clone https://github.com/RoboStack/jupyter-ros.git

# Add systemd service to start jupyter
#sudo rm /lib/systemd/system/zoef_jupyter.service
#sudo bash -c "echo '[Unit]' > /lib/systemd/system/zoef_jupyter.service"
#sudo bash -c "echo 'Description=Zoef Jupyter' >> /lib/systemd/system/zoef_jupyter.service"
#sudo bash -c "echo 'After=network.target' >> /lib/systemd/system/zoef_jupyter.service"
#sudo bash -c "echo 'After=ssh.service' >> /lib/systemd/system/zoef_jupyter.service"
#sudo bash -c "echo 'After=network-online.target' >> /lib/systemd/system/zoef_jupyter.service"
#sudo bash -c "echo '' >> /lib/systemd/system/zoef_jupyter.service"
#sudo bash -c "echo '[Service]' >> /lib/systemd/system/zoef_jupyter.service"
#sudo bash -c "echo 'ExecStart=/bin/bash -c \"source /home/zoef/jupyter/bin/activate && jupyter notebook --ip=\"0.0.0.0\" --NotebookApp.token=\"\" --NotebookApp.password=\"\"' >> /lib/systemd/system/zoef_jupyter.service"
#sudo bash -c "echo '' >> /lib/systemd/system/zoef_jupyter.service"
#sudo bash -c "echo '[Install]' >> /lib/systemd/system/zoef_jupyter.service"
#sudo bash -c "echo 'WantedBy=multi-user.target' >> /lib/systemd/system/zoef_jupyter.service"

#sudo systemctl daemon-reload
#sudo systemctl stop zoef_jupyter || /bin/true
#sudo systemctl start zoef_jupyter
#sudo systemctl enable zoef_jupyter

