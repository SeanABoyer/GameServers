#!/bin/bash
startLog "Updating System"
sudo dpkg --add-architecture i386
sudo apt-get update -y
finishLog "Updating System"

startLog "Installing Packages"
sudo apt-get install curl wget file tar bzip2 gzip unzip bsdmainutils python3 util-linux ca-certificates binutils bc jq tmux netcat lib32gcc-s1 lib32stdc++6 distro-info libsdl2-2.0-0:i386 netcat-openbsd -y
finishLog "Installing Packages"