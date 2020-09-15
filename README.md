# Terraform Basic Commands 
- --auto-approve : to approve yes and not type it in everytime 
- terraform apply : to apply changes
  - terraform apply -target aws_instance.name to add specific resource 
- terraform plan : to build out a plan 
- terraform init : to initialize the plugins based on provider in terraform files
- terraform destroy : to destroy the code 
  - specfic code can be destroyed by removing, else the above command removes everything. 
    - terraform destroy -target aws_instance.name 

- print value of a state in the end by adding this code 

Output "server_public_id" {
  value = ' ' 
}

# Terraform Variables 
- Terraform apply  -var-file example.tfvars - to pass a specific file

Subnet Calculator : https://mxtoolbox.com/SubnetCalculator.aspx 

Tutorial : https://www.youtube.com/watch?v=SLB_c_ayRMo

#mount ssd volumes on ETC Machine : 
- sudo mkfs.ext4 /dev/nvme0n1
- sudo mkdir /mnt/nvme0n1
- sudo mount /dev/nvme0n1 /mnt/nvme0n1
- df -hT
- sudo vi /etc/fstab
  -  echo "/dev/nvme1n1 /mnt/nvme1n1 ext4 noatime,data=writeback,barrier=0,nobh 0 0" | sudo cat  >> /etc/fstab
- sudo mount -a
- df -hT

Reference Document : https://www.youtube.com/watch?v=HPXnXkBzIHw

Reference Document for RAID Configuration : 
https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/raid-config.html

- sudo mdadm --create --verbose /dev/md0 --level=0 --name=vol_venmo_raid --raid-devices=3 /dev/nvme0n1 /dev/nvme1n1 /dev/nvme2n1u
- sudo cat /proc/mdstat
- sudo mdadm --detail /dev/md0
- sudo mkfs.ext4 -L vol_venmo_raid /dev/md0
- sudo mdadm --detail --scan | sudo tee -a /etc/mdadm.conf
- sudo dracut -H -f /boot/initramfs-$(uname -r).img $(uname -r)
- sudo mkdir -p /mnt/venmovol
- sudo mount LABEL=vol_venmo_raid /mnt/venmovol

Install : 
sudo apt-get install dracut

