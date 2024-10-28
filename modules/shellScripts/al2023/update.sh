#!/bin/bash
echo "[$(date '+%d/%m/%Y %H:%M:%S')][Starting] Updating System"
sudo yum update -y
echo "[$(date '+%d/%m/%Y %H:%M:%S')][Completed] Updating System"