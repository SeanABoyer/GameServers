#!/bin/bash
dir="/tmp/ssmAgent"
echo "[$(date '+%d/%m/%Y %H:%M:%S')][Starting] Setting up SSM Agent"
mkdir -p "$dir"
cd "$dir"
wget https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/debian_amd64/amazon-ssm-agent.deb
sudo dpkg -i amazon-ssm-agent.deb
echo "[$(date '+%d/%m/%Y %H:%M:%S')][Starting] Setting up SSM Agent"