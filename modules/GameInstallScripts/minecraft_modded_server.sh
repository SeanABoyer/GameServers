#!/bin/bash
username="${serviceAccountName}"
root_dir="${root_dir}"
min_ram="${minimum_ram}"
max_ram="${maximum_ram}"
zip_url="${zip_url}"
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
    startLog "Start Service"
    systemctl start gameService
    finishLog "Start Service"

    #EULA file is created after service is started
    startLog "Accept EULA"
    while [ ! -f "$root_dir/eula.txt" ]
    do
        generalLog "Unable to find [$root_dir/eula.txt]. Will check again in 10 seconds. "
        sleep 10
    done
    sudo -H -u $username bash -c "cd $root_dir && sed -i 's/eula=false/eula=true/g' $root_dir/eula.txt"
    finishLog "Accept EULA"
}

startLog "Setting up CronJob for Custom CloudWatch Metric"
cat > /home/$username/CloudWatchMetricGeneration.sh << EOF
aws cloudwatch put-metric-data --region us-west-2 --metric-name ConnectionsOn25565 --namespace CustomEC2 --unit Count --value \$(netstat -anp | grep -w 25565 | grep ESTABLISHED | wc -l) --dimensions InstanceId=\$(cat /sys/devices/virtual/dmi/id/board_asset_tag)
EOF

cat > /etc/systemd/system/gameService.timer << EOF
[Unit]
Description = Run script for CloudWatch Metric every 15 mins.
[Timer]
onBootSec=15min
onUnitActiveSec=15min

[Install]
WantedBy=timers.target
EOF
finishLog "Setting up CronJob for Custom CloudWatch Metric"

#If the ServerStart.sh does not exist, then download modpack and java to EFS share
if [ ! -f "$root_dir/startserver.sh" ]
then
    generalLog "Unable to find [$root_dir/startserver.sh]."
    startLog "Installing Java 8"
    sudo -H -u $username bash -c "cd $root_dir && mkdir java"
    sudo -H -u $username bash -c "cd $root_dir/java && wget https://github.com/adoptium/temurin8-binaries/releases/download/jdk8u345-b01/OpenJDK8U-jre_x64_linux_hotspot_8u345b01.tar.gz -O OpenJDK8.tar.gz"
    sudo -H -u $username bash -c "cd $root_dir/java && tar xf OpenJDK8.tar.gz"
    #ADD java to PATH 
    echo "export PATH=\$PATH:$root_dir/java/jdk8u345-b01-jre/bin" >> /etc/profile
    source /etc/profile
    finishLog "Installing Java 8"

    startLog "Downloading Modded Server"
    sudo -H -u $username bash -c "cd $root_dir && wget $zip_url -O Server.zip"
    finishLog "Downloading Modded Server"

    startLog "Installing Modded Server"
    sudo -H -u $username bash -c "cd $root_dir && unzip Server.zip"
    sudo -H -u $username bash -c "cd $root_dir && chmod +x startserver.sh"
#    sudo -H -u $username bash -c "cd $root_dir && chmod +x Install.sh"
#    sudo -H -u $username bash -c "source /etc/profile && cd $root_dir && sh Install.sh"
    finishLog "Installing Modded Server"
else
    generalLog "Found [$root_dir/startserver.sh]. "
fi

#If the services does not exist, then create it
if [ ! -f "/etc/systemd/system/gameService.service" ]
then
    generalLog "Unable to find [/etc/systemd/system/gameService.service]."
    startLog "Service Creation"
    touch /etc/systemd/system/gameService.service
    echo "[Unit]" >>/etc/systemd/system/gameService.service
    echo "Description=gameService" >>/etc/systemd/system/gameService.service
    echo "[Service]" >>/etc/systemd/system/gameService.service
    echo "Environment=PATH=$root_dir/java/jdk8u345-b01-jre/bin" >>/etc/systemd/system/gameService.service
    echo "User=$username" >>/etc/systemd/system/gameService.service
    echo "WorkingDirectory=$root_dir" >> /etc/systemd/system/gameService.service
    echo "ExecStart=\"$root_dir/startserver.sh\"" >>/etc/systemd/system/gameService.service
    echo "Restart=always" >>/etc/systemd/system/gameService.service
    echo "[Install]" >>/etc/systemd/system/gameService.service
    echo "WantedBy=multi-user.target" >>/etc/systemd/system/gameService.service

    systemctl daemon-reload
    systemctl enable gameService
    finishLog "Service Creation"
else
    generalLog "Found [/etc/systemd/system/gameService.service]."
fi


chown -R $username:$username $root_dir

startLog "Config Allowed Min & Max Memory"
sudo -H -u $username bash -c "cd $root_dir && sed -i 's/Xms6G/Xms$max_ram/g' $root_dir/startserver.sh"
sudo -H -u $username bash -c "cd $root_dir && sed -i 's/Xmx6G/Xmx$max_ram/g' $root_dir/startserver.sh"
finishLog "Config Allowed Min & Max Memory"

startService

