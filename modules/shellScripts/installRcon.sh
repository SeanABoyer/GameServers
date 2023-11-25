#!/bin/bash
dir="/tmp/rcon"

if [ ! -d "${rcon_dir}" ]
then
    echo "[$(date '+%d/%m/%Y %H:%M:%S')][Starting] Downloading RCON"
    #sudo npm update
    sudo mkdir -p "$dir"
    cd "$dir"
    sudo wget https://github.com/shobhit-pathak/cs2-rcon-panel/archive/refs/heads/master.zip -O cs2-rcon-panel.zip
    sudo unzip cs2-rcon-panel.zip
    sudo mv cs2-rcon-panel-master "${rcon_dir}"
    echo "[$(date '+%d/%m/%Y %H:%M:%S')][Completed] Downloading RCON"
else
    echo "[$(date '+%d/%m/%Y %H:%M:%S')][INFO] ${rcon_dir} already exists, not downloading."
fi

echo "[$(date '+%d/%m/%Y %H:%M:%S')][Starting] Installing NPM"
sudo apt-get install nodejs npm -y
cd "${rcon_dir}"
sudo npm install
sudo npm install -g nodemon
sudo chown -R ${username}:${username} "${rcon_dir}"
echo "[$(date '+%d/%m/%Y %H:%M:%S')][Completed] Installing NPM"


startScriptFullPath="$rcon_dir/startServer.sh"
stopScriptFullPath="$rcon_dir/stopServer.sh"
if [ ! -f "${startScriptFullPath}" ]
then
    echo "[$(date '+%d/%m/%Y %H:%M:%S')][Starting] Creating Wrapper Start Script: ${gamename}"
    touch ${startScriptFullPath}
    echo "#!/bin/bash" >> "${startScriptFullPath}"
    echo "nodemon ${rcon_dir}/app.js start &" >> "${startScriptFullPath}"
    sudo chown GameAdmin:GameAdmin "${startScriptFullPath}"
    sudo chmod +x "${startScriptFullPath}"
    echo "[$(date '+%d/%m/%Y %H:%M:%S')][Completed] Creating Wrapper Start Script: ${gamename}"
else
    echo "[$(date '+%d/%m/%Y %H:%M:%S')][INFO] Wrapper Start Script: ${startScriptFullPath} exists"
fi


if [ ! -f "${stopScriptFullPath}" ]
then
    echo "[$(date '+%d/%m/%Y %H:%M:%S')][Starting] Creating Wrapper Stop Script: ${gamename}"
    touch "${stopScriptFullPath}"
    echo "#!/bin/bash" >> "${stopScriptFullPath}"
    echo "nodemon ${rcon_dir}/app.js stop" >> "${stopScriptFullPath}"
    sudo chown GameAdmin:GameAdmin "${stopScriptFullPath}"
    sudo chmod +x "${stopScriptFullPath}"
    echo "[$(date '+%d/%m/%Y %H:%M:%S')][Completed] Creating Wrapper Stop Script: ${gamename}"
else
    echo "[$(date '+%d/%m/%Y %H:%M:%S')][INFO] Wrapper Stop Script: ${stopScriptFullPath} exists"
fi