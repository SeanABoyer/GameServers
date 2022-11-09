#!/bin/bash
password="${password}"
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
sudo apt-get update -y
sudo apt-get upgrade -y
finishLog "Updating System"

startLog "Installing Packages"
sudo apt-get install unzip 
finishLog "Installing Packages"

startLog "Creating User and Changing User"
sudo useradd mcserver -p $password -m
sudo chown -R mcserver:mcserver /home/mcserver
finishLog "Creating User and Changing User"

startLog "Downloading SevTech"
sudo -H -u mcserver bash -c "cd ~ && wget https://mediafilez.forgecdn.net/files/3570/46/SevTech_Ages_Server_3.2.3.zip -O sevtech-server.zip"
finishLog "Downloading SevTech"

startLog "Installing Java 8"
sudo -H -u mcserver bash -c "cd ~ && mkdir java"
sudo -H -u mcserver bash -c "cd ~/java && wget https://github.com/adoptium/temurin8-binaries/releases/download/jdk8u345-b01/OpenJDK8U-jre_x64_linux_hotspot_8u345b01.tar.gz -O OpenJDK8.tar.gz"
sudo -H -u mcserver bash -c "cd ~/java && tar xf OpenJDK8.tar.gz"
#ADD java to PATH 
echo "export PATH=\$PATH:/home/mcserver/java/jdk8u345-b01-jre/bin" >> /etc/profile
source /etc/profile
finishLog "Installing Java 8"

startLog "Installing SevTech"
sudo -H -u mcserver bash -c "cd ~ && unzip sevtech-server.zip"
sudo -H -u mcserver bash -c "source /etc/profile && cd ~ && sh Install.sh"
finishLog "Installing SevTech"

startLog "Config SevTech"
sudo -H -u mcserver bash -c "cd ~ && sed -i 's/eula=false/eula=true/g' /home/mcserver/eula.txt"
sudo -H -u mcserver bash -c "cd ~ && sed -i 's/MAX_RAM=\"4096M\"/MAX_RAM=\"6656M\"/g' /home/mcserver/settings.sh"
sudo -H -u mcserver bash -c "cd ~ && sed -i 's/MIN_RAM=\"1024M\"/MIN_RAM=\"4096M\"/g' /home/mcserver/settings.sh"
finishLog "Config SevTech"

startLog "Starting SevTech"
sudo -H -u mcserver bash -c "source /etc/profile && cd ~ && sh ServerStart.sh &>/home/mcserver/serverLogs.log &"
finishLog "Starting SevTech"