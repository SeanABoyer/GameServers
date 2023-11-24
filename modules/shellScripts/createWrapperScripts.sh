#!/bin/bash
startFileFullPath=${root_dir}/startServer.sh
stopFileFullPath=${root_dir}/stopServer.sh

if [! -f "$startFileFullPath" ]
then
    echo "[$(date '+%d/%m/%Y %H:%M:%S')][Starting] Creating Wrapper Start Script: ${gamename}"
    touch $startFileFullPath
    echo "bash ${$root_dir}/cs2server update >> $startFileFullPath"
    echo "bash ${$root_dir}/cs2server start >> $startFileFullPath"
    sudo chown GameAdmin:GameAdmin $startFileFullPath
    sudo chmod +x $startFileFullPath
    echo "[$(date '+%d/%m/%Y %H:%M:%S')][Completed] Creating Wrapper Start Script: ${gamename}"
else
    echo "[$(date '+%d/%m/%Y %H:%M:%S')][INFO] Wrapper Start Script: $startFileFullPath exists."
fi


if [! -f "$stopFileFullPath" ]
then
    echo "[$(date '+%d/%m/%Y %H:%M:%S')][Starting] Creating Wrapper Stop Script: ${gamename}"
    touch $stopFileFullPath
    echo "bash ${$root_dir}/cs2server stop >> $stopFileFullPath"
    sudo chown GameAdmin:GameAdmin $stopFileFullPath
    sudo chmod +x $stopFileFullPath
    echo "[$(date '+%d/%m/%Y %H:%M:%S')][Completed] Creating Wrapper Stop Script: ${gamename}"
else
    echo "[$(date '+%d/%m/%Y %H:%M:%S')][INFO] Wrapper Stop Script: $stopFileFullPath exists."
fi