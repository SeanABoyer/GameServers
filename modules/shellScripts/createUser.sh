#!/bin/bash
username="${username}"
password="${password}"

startLog "Creating User:$username"
sudo useradd $username -p $password -m
sudo chown -R $username:$username /home/$username
finishLog "Creating User:$username"