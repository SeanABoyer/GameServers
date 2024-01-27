#!/bin/bash
tempDir="/tmp/${addonName}"
echo "[$(date '+%d/%m/%Y %H:%M:%S')][Starting] Downloading ${addonName}"
sudo mkdir -p "$tempDir"
cd "$tempDir"
sudo wget "${link}" -O ${addonName}.zip
sudo unzip ${addonName}.zip
echo "[$(date '+%d/%m/%Y %H:%M:%S')][Completed] Downloading ${addonName}"

echo "[$(date '+%d/%m/%Y %H:%M:%S')][Starting] Moving ${addonName} to ${directory}"
sudo cp addons "${directory}" -r
echo "[$(date '+%d/%m/%Y %H:%M:%S')][Completed] Moving ${addonName} to ${directory}"

echo "[$(date '+%d/%m/%Y %H:%M:%S')][Starting] Granting Ownership of ${directory} to ${username}"
sudo chown "${username}":"${username}" "${directory}" -R
echo "[$(date '+%d/%m/%Y %H:%M:%S')][Completed] Granting Ownership of ${directory} to ${username}"

