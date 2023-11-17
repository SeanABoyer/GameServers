gamename="${gamename}"

echo "[$(date '+%d/%m/%Y %H:%M:%S')][Starting] Creating Service:$gamename"
touch /etc/systemd/system/$gamename.service
echo "[Unit]" >>/etc/systemd/system/$gamename.service
echo "Description=$gamename" >>/etc/systemd/system/$gamename.service
echo "[Service]" >>/etc/systemd/system/$gamename.service
echo "User=$username" >>/etc/systemd/system/$gamename.service
echo "WorkingDirectory=$root_dir" >> /etc/systemd/system/$gamename.service
echo "ExecStart=\"$root_dir/$lgsmfilename $lgsmstartcommand\"" >>/etc/systemd/system/$gamename.service
echo "Restart=always" >>/etc/systemd/system/$gamename.service
echo "[Install]" >>/etc/systemd/system/$gamename.service
echo "WantedBy=multi-user.target" >>/etc/systemd/system/$gamename.service

systemctl daemon-reload
systemctl enable $gamename
echo "[$(date '+%d/%m/%Y %H:%M:%S')][Completed] Creating Service:$gamename"