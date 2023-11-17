root_dir="${root_dir}"
filesystem_id="${filesystem_id}"
username="${username}"
dir="/tmp/efsUtils"
startLog "Mounting EFS"
echo "SEAN $root_dir SEAN"
sudo apt install git binutils -y
mkdir -p "$dir"
cd "$dir"
sudo git clone https://github.com/aws/efs-utils .
sudo ./build-deb.sh
sudo apt install ./build/amazon-efs-utils*deb -y

mkdir -p "$root_dir"
cd "$root_dir"

sudo chown -R $username:$username $root_dir
generalLog "Attempting to mount $filesystem_id to $root_dir"
sudo mount -t efs -o tls,iam "$filesystem_id" $root_dir
sudo echo "$filesystem_id:/ $root_dir efs _netdev,noresvport,tls,iam 0 0" >> /etc/fstab
finishLog "Mounting EFS"