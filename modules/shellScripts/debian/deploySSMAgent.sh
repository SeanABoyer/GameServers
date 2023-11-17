#!/bin/bash
dir="/tmp/ssmAgent"
bash -c "source utility.sh; startLog" "Updating System"
#startLog "Updating System"
mkdir -p "$dir"
cd "$dir"
wget https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/debian_amd64/amazon-ssm-agent.deb
sudo dpkg -i amazon-ssm-agent.deb
bash -c "source utility.sh; finishLog" "Updating System"
#finishLog "Updating System"