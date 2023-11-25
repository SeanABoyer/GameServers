#!/bin/bash
dir="/tmp/rcon"
rcon_dir="${root_dir}/rcon-web-admin"
if [ ! -f $rcon_dir ]
then
    echo "[$(date '+%d/%m/%Y %H:%M:%S')][Starting] Installing RCON"
    sudo apt-get install nodejs npm
    sudo npm update npm -g
    sudo mkdir -p "$dir"
    cd "$dir"
    sudo wget https://codeload.github.com/rcon-web-admin/rcon-web-admin/zip/master -O rcon-web-admin.zip
    sudo unzip rcon-web-admin.zip
    sudo mv rcon-web-admin-master "$rcon_dir"
    cd "$rcon_dir"
    sudo npm install
    sudo node src/main.js install-core-widgets
    sudo chown -R ${username}:${username} "$rcon_dir"
    echo "[$(date '+%d/%m/%Y %H:%M:%S')][Completed] Installing RCON"
else
    echo "[$(date '+%d/%m/%Y %H:%M:%S')][INFO] $rconDir already exists."
fi