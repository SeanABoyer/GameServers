root_dir="${root_dir}"
filesystem_id="${filesystem_id}"
username="${username}"

startLog "Mounting EFS"
sudo apt install git binutils -y
sudo mkdir "/tmp/$filesystem_id"
cd "/tmp/${filesystem_id}"
sudo git clone https://github.com/aws/efs-utils .
sudo ./build-deb.sh
sudo apt install ./build/amazon-efs-utils*deb -y

sudo mkdir -p $root_dir
mkdir -p /mnt/test
sudo mkdir -p /mnt/test2
sudo chown -R $username:$username $root_dir
generalLog "Attempting to mount $filesystem_id to $root_dir"
sudo mount -t efs -o tls,iam "$filesystem_id" $root_dir
sudo echo "$filesystem_id:/ $root_dir efs _netdev,noresvport,tls,iam 0 0" >> /etc/fstab
finishLog "Mounting EFS"