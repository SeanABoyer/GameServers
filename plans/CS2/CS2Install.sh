#!/bin/bash
lgsmFileFullPath="${game_dir}/${lgsmfilename}"
if [ ! -f "$lgsmFileFullPath" ]
then
    echo "[$(date '+%d/%m/%Y %H:%M:%S')][Starting] Download linuxgsm.sh and installing CS2 server"
    sudo mkdir -p "${game_dir}"
    sudo -H -u GameAdmin bash -c "cd ${game_dir} && wget -O linuxgsm.sh https://linuxgsm.sh && chmod +x linuxgsm.sh && bash linuxgsm.sh ${lgsmfilename}"
    sudo -H -u GameAdmin bash -c "mkdir ${game_dir}/lgsm/config-lgsm"
    sudo -H -u GameAdmin bash -c "mkdir ${game_dir}/lgsm/config-lgsm/cs2server"
    sudo -H -u GameAdmin bash -c "echo 'steamuser=\"${steamUsername}\"' >> ${game_dir}/lgsm/config-lgsm/cs2server/common.cfg"
    sudo -H -u GameAdmin bash -c "echo 'steampass=\"${steamPassword}\"' >> ${game_dir}/lgsm/config-lgsm/cs2server/common.cfg"
    sudo -H -u GameAdmin bash -c "echo 'gslt=\"$gslt\"' >> ${game_dir}/lgsm/config-lgsm/cs2server/cs2server.cfg"
    sudo -H -u GameAdmin bash -c "cd ${game_dir} && yes | ./${lgsmfilename} install"
    echo "[$(date '+%d/%m/%Y %H:%M:%S')][Completed]  Download linuxgsm.sh and installing CS2 server" 
else
    echo "[$(date '+%d/%m/%Y %H:%M:%S')][INFO] $lgsmFileFullPath already exists. "
fi

if [ ! -f "${startScriptFullPath}" ]
then
    echo "[$(date '+%d/%m/%Y %H:%M:%S')][Starting] Creating Wrapper Start Script: ${gamename}"
    touch ${startScriptFullPath}
    echo "#!/bin/bash" >> "${startScriptFullPath}"
    echo "bash ${game_dir}/cs2server update >> ${startScriptFullPath}"
    echo "bash ${game_dir}/cs2server start >> ${startScriptFullPath}"
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
    echo "bash ${game_dir}/cs2server stop >> ${stopScriptFullPath}"
    sudo chown GameAdmin:GameAdmin "${stopScriptFullPath}"
    sudo chmod +x "${stopScriptFullPath}"
    echo "[$(date '+%d/%m/%Y %H:%M:%S')][Completed] Creating Wrapper Stop Script: ${gamename}"
else
    echo "[$(date '+%d/%m/%Y %H:%M:%S')][INFO] Wrapper Stop Script: ${stopScriptFullPath} exists"
fi