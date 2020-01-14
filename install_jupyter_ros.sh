#!/bin/bash

# install basic python tools
sudo apt install python2.7 python-virtualenv python-dev git

# create and activate virtualenv
cd /
sudo python -m virtualenv jupyter
source /jupyter/bin/activate

# install jupyros
pip install jupyter bqplot pyyaml ipywidgets
pip install jupyros
jupyter nbextension enable --py --sys-prefix jupyros

export JUPYTER_CONFIG_DIR=/jupyter_config
jupyter notebook --generate-config
sed -i -e "s/#c.NotebookApp.ip = 'localhost'/c.NotebookApp.ip = '0.0.0.0'/g" /jupyter_config/jupyter_notebook_config.py

deactivate

# TEMP: download examples
git clone https://github.com/RoboStack/jupyter-ros.git
