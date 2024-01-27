#!/bin/bash
tempDir="/tmp/metamod"
echo "[$(date '+%d/%m/%Y %H:%M:%S')][Starting] Downloading MetaMod"
#sudo npm update
sudo mkdir -p "$tempDir"
cd "$tempDir"
sudo wget "${link}" -O metamod.tar.gz
sudo tar -xvzf metamod.tar.gz
echo "[$(date '+%d/%m/%Y %H:%M:%S')][Completed] Downloading MetaMod"

echo "[$(date '+%d/%m/%Y %H:%M:%S')][Starting] Moving MetaMod to ${directory}"
sudo cp addons "${directory}" -r
echo "[$(date '+%d/%m/%Y %H:%M:%S')][Completed] Moving MetaMod to ${directory}"

echo "[$(date '+%d/%m/%Y %H:%M:%S')][Starting] Granting Ownership of ${directory} to ${username}"
sudo chown "${username}":"${username}" "${directory}" -R
echo "[$(date '+%d/%m/%Y %H:%M:%S')][Completed] Granting Ownership of ${directory} to ${username}"