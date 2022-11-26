#!/bin/bash
password="${password}"
filesystem_id="${filesystem_id}"
gamename="${gamename}"
root_dir="/mnt/$gamename"
min_ram="${minimum_ram}"
max_ram="${maximum_ram}"
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
generalLog () {
    log_message=$1
    date=$(date '+%d/%m/%Y %H:%M:%S')
    echo "[$date][Info] $log_message"
}

function startService(){
    #TODO change RAM based on variables
    startLog "Config Allowed Min & Max Memory"
    sudo -H -u mcserver bash -c "cd $root_dir && sed -i 's/MAX_RAM=\"4096M\"/MAX_RAM=\"$max_ram\"/g' $root_dir/settings.sh"
    sudo -H -u mcserver bash -c "cd $root_dir && sed -i 's/MIN_RAM=\"1024M\"/MIN_RAM=\"$min_ram\"/g' $root_dir/settings.sh"
    finishLog "Config Allowed Min & Max Memory"

    startLog "Start Service"
    systemctl start mcserver
    finishLog "Start Service"

    #EULA file is created after service is started
    startLog "Accept EULA"
    while [ ! -f "$root_dir/eula.txt" ]
    do
        generalLog "Unable to find [$root_dir/eula.txt]. Will check again in 10 seconds. "
        sleep 10
    done
    sudo -H -u mcserver bash -c "cd $root_dir && sed -i 's/eula=false/eula=true/g' $root_dir/eula.txt"
    finishLog "Accept EULA"
}


startLog "Updating System"
yum install amazon-efs-utils -y
yum update -y
yum upgrade -y
finishLog "Updating System"

startLog "Mounting EFS"
mkdir -p $root_dir
generalLog "Attempting to mount $filesystem_id to $root_dir"
mount -t efs -o tls,iam "$filesystem_id" $root_dir
echo "$filesystem_id:/ $root_dir efs _netdev,noresvport,tls,iam 0 0" >> /etc/fstab
finishLog "Mounting EFS"

startLog "Creating User and Changing User"
sudo useradd mcserver -p $password -m
sudo chown -R mcserver:mcserver $root_dir
finishLog "Creating User and Changing User"

startLog "Setting up CronJob for Custom CloudWatch Metric"
cat > /home/mcserver/CloudWatchMetricGeneration.sh << EOF
aws cloudwatch put-metric-data --region us-west-2 --metric-name ConnectionsOn25565 --namespace CustomEC2 --unit Count --value \$(netstat -anp | grep -w 25565 | grep ESTABLISHED | wc -l) --dimensions InstanceID=\$(cat /sys/devices/virtual/dmi/id/board_asset_tag)
EOF

chmod +x /home/mcserver/CloudWatchMetricGeneration.sh

(crontab -l; echo "*/15 * * * * /home/mcserver/CloudWatchMetricGeneration.sh") | sort -u | crontab -
finishLog "Setting up CronJob for Custom CloudWatch Metric"

#If the ServerStart.sh does not exist, then download modpack and java to EFS share
if [ ! -f "$root_dir/ServerStart.sh" ]
then
    generalLog "Unable to find [$root_dir/ServerStart.sh]."
    startLog "Installing Java 8"
    sudo -H -u mcserver bash -c "cd $root_dir && mkdir java"
    sudo -H -u mcserver bash -c "cd $root_dir/java && wget https://github.com/adoptium/temurin8-binaries/releases/download/jdk8u345-b01/OpenJDK8U-jre_x64_linux_hotspot_8u345b01.tar.gz -O OpenJDK8.tar.gz"
    sudo -H -u mcserver bash -c "cd $root_dir/java && tar xf OpenJDK8.tar.gz"
    #ADD java to PATH 
    echo "export PATH=\$PATH:$root_dir/java/jdk8u345-b01-jre/bin" >> /etc/profile
    source /etc/profile
    finishLog "Installing Java 8"

    startLog "Downloading SevTech"
    sudo -H -u mcserver bash -c "cd $root_dir && wget https://mediafilez.forgecdn.net/files/3583/116/SevTech_Sky_Server_3.2.3.zip -O sevtech-server.zip"
    finishLog "Downloading SevTech"

    startLog "Installing SevTech"
    sudo -H -u mcserver bash -c "cd $root_dir && unzip sevtech-server.zip"
    sudo -H -u mcserver bash -c "cd $root_dir && chmod +x ServerStart.sh"
    sudo -H -u mcserver bash -c "cd $root_dir && chmod +x Install.sh"
    sudo -H -u mcserver bash -c "source /etc/profile && cd $root_dir && sh Install.sh"
    finishLog "Installing SevTech"
else
    generalLog "Found [$root_dir/ServerStart.sh]. "
fi

#If the services does not exist, then create it
if [ ! -f "/etc/systemd/system/mcserver.service" ]
then
    generalLog "Unable to find [/etc/systemd/system/mcserver.service]."
    startLog "Service Creation"
    touch /etc/systemd/system/mcserver.service
    echo "[Unit]" >>/etc/systemd/system/mcserver.service
    echo "Description=MCServer" >>/etc/systemd/system/mcserver.service
    echo "[Service]" >>/etc/systemd/system/mcserver.service
    echo "Environment=PATH=$root_dir/java/jdk8u345-b01-jre/bin" >>/etc/systemd/system/mcserver.service
    echo "User=mcserver" >>/etc/systemd/system/mcserver.service
    echo "WorkingDirectory=$root_dir" >> /etc/systemd/system/mcserver.service
    echo "ExecStart=\"$root_dir/ServerStart.sh\"" >>/etc/systemd/system/mcserver.service
    echo "Restart=always" >>/etc/systemd/system/mcserver.service
    echo "[Install]" >>/etc/systemd/system/mcserver.service
    echo "WantedBy=multi-user.target" >>/etc/systemd/system/mcserver.service

    systemctl daemon-reload
    systemctl enable mcserver
    finishLog "Service Creation"
else
    generalLog "Found [/etc/systemd/system/mcserver.service]."
fi

startService

