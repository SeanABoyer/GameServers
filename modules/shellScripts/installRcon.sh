#!/bin/bash
dir="/tmp/rcon"
root_dir="/mnt/CS2"
rcon_dir="${root_dir}/cs2-rcon-panel-master"

sudo apt-get install nodejs npm -y

if [ ! -d $rcon_dir ]
then
    echo "[$(date '+%d/%m/%Y %H:%M:%S')][Starting] Installing RCON"
    #sudo npm update
    sudo mkdir -p "$dir"
    cd "$dir"
    sudo wget https://github.com/shobhit-pathak/cs2-rcon-panel/archive/refs/heads/master.zip -O cs2-rcon-panel.zip
    sudo unzip cs2-rcon-panel.zip
    sudo mv cs2-rcon-panel-master "$rcon_dir"
    cd "$rcon_dir"
    sudo npm install
    sudo npm install -g nodemon
    sudo chown -R ${username}:${username} "$rcon_dir"
    echo "[$(date '+%d/%m/%Y %H:%M:%S')][Completed] Installing RCON"
else
    echo "[$(date '+%d/%m/%Y %H:%M:%S')][INFO] $rconDir already exists."
fi