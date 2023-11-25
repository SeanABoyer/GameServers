#!/bin/bash
lgsmFileFullPath="${root_dir}/${lgsmfilename}"
if [ ! -f "$lgsmFileFullPath" ]
then
    echo "[$(date '+%d/%m/%Y %H:%M:%S')][Starting] Download linuxgsm.sh and installing CS2 server"
    sudo -H -u GameAdmin bash -c "cd ${root_dir} && wget -O linuxgsm.sh https://linuxgsm.sh && chmod +x linuxgsm.sh && bash linuxgsm.sh ${lgsmfilename}"
    sudo -H -u GameAdmin bash -c "mkdir ${root_dir}/lgsm/config-lgsm"
    sudo -H -u GameAdmin bash -c "mkdir ${root_dir}/lgsm/config-lgsm/cs2server"
    sudo -H -u GameAdmin bash -c "echo 'steamuser=\"${steamUsername}\"' >> ${root_dir}/lgsm/config-lgsm/cs2server/common.cfg"
    sudo -H -u GameAdmin bash -c "echo 'steampass=\"${steamPassword}\"' >> ${root_dir}/lgsm/config-lgsm/cs2server/common.cfg"
    sudo -H -u GameAdmin bash -c "echo 'gslt=\"$gslt\"' >> ${root_dir}/lgsm/config-lgsm/cs2server/cs2server.cfg"
    sudo -H -u GameAdmin bash -c "cd ${root_dir} && yes | ./${lgsmfilename} install"
    echo "[$(date '+%d/%m/%Y %H:%M:%S')][Completed]  Download linuxgsm.sh and installing CS2 server"
else
    echo "[$(date '+%d/%m/%Y %H:%M:%S')][INFO] $lgsmFileFullPath already exists. "
fi

startFileFullPath="${root_dir}/startServer.sh"
stopFileFullPath="${root_dir}/stopServer.sh"

if [ ! -f "$startFileFullPath" ]
then
    echo "[$(date '+%d/%m/%Y %H:%M:%S')][Starting] Creating Wrapper Start Script: ${gamename}"
    touch $startFileFullPath
    echo "bash ${root_dir}/cs2server update >> $startFileFullPath"
    echo "bash ${root_dir}/cs2server start >> $startFileFullPath"
    sudo chown GameAdmin:GameAdmin $startFileFullPath
    sudo chmod +x $startFileFullPath
    echo "[$(date '+%d/%m/%Y %H:%M:%S')][Completed] Creating Wrapper Start Script: ${gamename}"
else
    echo "[$(date '+%d/%m/%Y %H:%M:%S')][INFO] Wrapper Start Script: $startFileFullPath exists"
fi


if [ ! -f "$stopFileFullPath" ]
then
    echo "[$(date '+%d/%m/%Y %H:%M:%S')][Starting] Creating Wrapper Stop Script: ${gamename}"
    touch $stopFileFullPath
    echo "bash ${root_dir}/cs2server stop >> $stopFileFullPath"
    sudo chown GameAdmin:GameAdmin $stopFileFullPath
    sudo chmod +x $stopFileFullPath
    echo "[$(date '+%d/%m/%Y %H:%M:%S')][Completed] Creating Wrapper Stop Script: ${gamename}"
else
    echo "[$(date '+%d/%m/%Y %H:%M:%S')][INFO] Wrapper Stop Script: $stopFileFullPath exists"
fi