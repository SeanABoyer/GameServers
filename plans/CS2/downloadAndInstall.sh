#!/bin/bash
steamUsername="${steamUsername}"
steamPassword="${steamPassword}"
lgsmfilename="${lgsmfilename}"
root_dir="${root_dir}"
if [! -f "$root_dir" ]
then
    echo "[$(date '+%d/%m/%Y %H:%M:%S')][Starting] Download linuxgsm.sh and install server"
    sudo -H -u GameAdmin bash -c "cd $root_dir && wget -O linuxgsm.sh https://linuxgsm.sh && chmod +x linuxgsm.sh && bash linuxgsm.sh $lgsmfilename"
    sudo -H -u GameAdmin bash -c "mkdir $root_dir/lgsm/config-lgsm"
    sudo -H -u GameAdmin bash -c "mkdir $root_dir/lgsm/config-lgsm/cs2server"
    sudo -H -u GameAdmin bash -c "echo 'steamuser=\"$steamUsername\"' >> $root_dir/lgsm/config-lgsm/cs2server/common.cfg"
    sudo -H -u GameAdmin bash -c "echo 'steampass=\"$steamPassword\"' >> $root_dir/lgsm/config-lgsm/cs2server/common.cfg"
    sudo -H -u GameAdmin bash -c "echo 'gslt=\"$gslt\"' >> $root_dir/lgsm/config-lgsm/cs2server/cs2server.cfg"
    sudo -H -u GameAdmin bash -c "cd $root_dir && yes | ./$lgsmfilename install"
    echo "[$(date '+%d/%m/%Y %H:%M:%S')][Completed] Download linuxgsm.sh and install server"
else
    echo "[$(date '+%d/%m/%Y %H:%M:%S')][INFO] ${root_dir} already exists."
fi