#!/bin/bash
tempDir="/tmp/metamod"
if [ ! -d "${directory}" ]
then
    echo "[$(date '+%d/%m/%Y %H:%M:%S')][Starting] Downloading MetaMod"
    #sudo npm update
    sudo mkdir -p "$tempDir"
    cd "$tempDir"
    sudo wget "${link}" -O metamod.tar.gz
    sudo tar -xvzf metamod.tar.gz
    #Copy Files to ${metaModDirectory}
    echo "[$(date '+%d/%m/%Y %H:%M:%S')][Completed] Downloading MetaMod"
else
    echo "[$(date '+%d/%m/%Y %H:%M:%S')][INFO] ${directory} already exists, not downloading."
fi
