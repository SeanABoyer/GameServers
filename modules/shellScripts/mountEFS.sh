startLog "Mounting EFS"
mkdir -p $root_dir
generalLog "Attempting to mount $filesystem_id to $root_dir"
mount -t efs -o tls,iam "$filesystem_id" $root_dir
echo "$filesystem_id:/ $root_dir efs _netdev,noresvport,tls,iam 0 0" >> /etc/fstab
finishLog "Mounting EFS"