#!/bin/bash
password="${password}"
steamUsername="${steamUsername}"
steamPassword="${steamPassword}"
gslt="${gslt}"
startLog () {
    log_message=$1
    date=$(date '+%d/%m/%Y %H:%M:%S')
    echo "[$date][Starting] $log_message"
}
finishLog () {
    log_message=$1
    date=$(date '+%d/%m/%Y %H:%M:%S')
    echo "[$date][Completed] $log_message"
}

startLog "Updating System"
sudo dpkg --add-architecture i386
sudo apt update -y
finishLog "Updating System"

startLog "Installing Packages"
sudo apt install curl wget file tar bzip2 gzip unzip bsdmainutils python3 util-linux ca-certificates binutils bc jq tmux netcat lib32gcc-s1 lib32stdc++6 distro-info libsdl2-2.0-0:i386 netcat-openbsd-y
finishLog "Installing Packages"

startLog "Creating User"
sudo useradd cs2server -p $password -m
sudo chown -R cs2server:cs2server /home/cs2server
finishLog "Creating User"

startLog "Download linuxgsm.sh and install server"
sudo -H -u cs2server bash -c "cd ~ && wget -O linuxgsm.sh https://linuxgsm.sh && chmod +x linuxgsm.sh && bash linuxgsm.sh cs2server"
sudo -H -u cs2server bash -c "mkdir ~/lgsm/config-lgsm"
sudo -H -u cs2server bash -c "mkdir ~/lgsm/config-lgsm/cs2server"
sudo -H -u cs2server bash -c "echo 'steamuser=\"$steamUsername\"' >> ~/lgsm/config-lgsm/cs2server/common.cfg"
sudo -H -u cs2server bash -c "echo 'steampass=\"$steamPassword\"' >> ~/lgsm/config-lgsm/cs2server/common.cfg"
sudo -H -u cs2server bash -c "echo 'gslt=\"$gslt\"' >> ~/lgsm/config-lgsm/cs2server/common.cfg"
sudo -H -u cs2server bash -c "cd ~ && yes | ./cs2server install"
finishLog "Download linuxgsm.sh and install server"


startLog "Start server"
sudo -H -u cs2server bash -c "cd ~ && ./cs2server start"
finishLog "Start server"