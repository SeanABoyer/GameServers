#!/bin/bash
echo "[$(date '+%d/%m/%Y %H:%M:%S')][Starting] Updating System"
sudo dpkg --add-architecture i386
sudo apt-get update -y
echo "[$(date '+%d/%m/%Y %H:%M:%S')][Completed] Updating System"

echo "[$(date '+%d/%m/%Y %H:%M:%S')][Starting] Installing Packages"
sudo apt-get install curl wget file tar bzip2 gzip unzip bsdmainutils python3 util-linux ca-certificates binutils bc jq tmux netcat lib32gcc-s1 lib32stdc++6 distro-info libsdl2-2.0-0:i386 netcat-openbsd -y
echo "[$(date '+%d/%m/%Y %H:%M:%S')][Completed] Installing Packages"