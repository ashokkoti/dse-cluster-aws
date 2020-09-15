provider "aws" {
  region  = "us-east-1"
  shared_credentials_file = "/Users/davidjoy/.aws/credentials"
  profile = "fieldops"
}

# Creates VPC 
resource "aws_vpc" "venmo_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "venmo_vpc"
  }
}

# Creates Subnet 
resource "aws_subnet" "venmo_subnet" {
  vpc_id     = aws_vpc.venmo_vpc.id
  cidr_block = "10.0.0.0/24"
  availability_zone = var.availability_zone

  tags = {
    Name = "venmo_subnet"
  }
}

# Create Internet Gateway 
resource "aws_internet_gateway" "venmo_igw" {
  vpc_id = aws_vpc.venmo_vpc.id

  tags = {
        Name = "venmo_igw"
  }
}

# Create Route table 
resource "aws_route_table" "venmo_rt" {
  vpc_id = aws_vpc.venmo_vpc.id
  route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.venmo_igw.id
  }

  tags = {
        Name = "venmo_rt"
  }
}

resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.venmo_subnet.id
  route_table_id = aws_route_table.venmo_rt.id
}


# Security group rules:
# - open SSH port (22) from anywhere
#
resource "aws_security_group" "sg_ssh" {
   name = "sg_ssh"
   vpc_id     = aws_vpc.venmo_vpc.id

   ingress {
      from_port = 22
      to_port = 22
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
   }

   egress {
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = ["0.0.0.0/0"]
   }
}

# Security group rules: 
# - open OpsCenter HTTPS access from anywhere
#   (assuming OpsCenter web access is enabled)
#
resource "aws_security_group" "sg_opsc_web" {
   name = "sg_opsc_web"
   vpc_id     = aws_vpc.venmo_vpc.id

   # OpsCenter server HTTPS port
   ingress {
      from_port = 8443
      to_port = 8443
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
   }

   # OpsCenter server HTTP port
   ingress {
      from_port = 8888
      to_port = 8888
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
   }
}

resource "aws_security_group" "sg_internal_only" {
   name = "sg_internal_only"
   vpc_id     = aws_vpc.venmo_vpc.id
}

resource "aws_security_group" "sg_opsc_node" {
   name = "sg_opsc_node"
   vpc_id     = aws_vpc.venmo_vpc.id

   # Outbound: allow everything to everywhere
   egress {
      from_port = 0
      to_port = 0
      protocol = "-1"
      security_groups = [aws_security_group.sg_internal_only.id]
   }

   # SMTP emal alerting port, non-SSL
   ingress {
      from_port = 25
      to_port = 25
      protocol = "tcp"
      security_groups = [aws_security_group.sg_internal_only.id]
   }

   # SMTP emal alerting port, SSL
   ingress {
      from_port = 465
      to_port = 465
      protocol = "tcp"
      security_groups = [aws_security_group.sg_internal_only.id]
   }

   # SNMP listening port
   ingress {
      from_port = 162
      to_port = 162
      protocol = "udp"
      security_groups = [aws_security_group.sg_internal_only.id]
   }

   # OpsCenter Definitions port
   ingress {
      from_port = 443
      to_port = 443
      protocol = "tcp"
      security_groups = [aws_security_group.sg_internal_only.id]
   }

   # LCM proxy port
   ingress {
      from_port = 3128
      to_port = 3128
      protocol = "tcp"
      security_groups = [aws_security_group.sg_internal_only.id]
   }

   # Stomp ports: agent -> opsc
   ingress {
      from_port = 61619
      to_port = 61620
      protocol = "tcp"
      security_groups = [aws_security_group.sg_internal_only.id]
   }
}

# Security group rules:
# - Ports required for proper DSE function
#
resource "aws_security_group" "sg_dse_node" {
   name = "sg_dse_node"
   vpc_id     = aws_vpc.venmo_vpc.id

   # Outbound: allow everything to everywhere
   egress {
      from_port = 0
      to_port = 0
      protocol = "-1"
      security_groups = [aws_security_group.sg_internal_only.id]
   }

   # DSEFS inter-node communication port
   ingress {
      from_port = 5599 
      to_port = 5599
      protocol = "tcp"
      security_groups = [aws_security_group.sg_internal_only.id]
   }

   # DSE inter-node cluster communication port
   # - 7000: No SSL
   # - 7001: With SSL
   ingress {
      from_port = 7000
      to_port = 7001
      protocol = "tcp"
      security_groups = [aws_security_group.sg_internal_only.id]
   }

   # Spark master inter-node communication port
   ingress {
      from_port = 7077
      to_port = 7077
      protocol = "tcp"
      security_groups = [aws_security_group.sg_internal_only.id]
   }

   # JMX monitoring port
   ingress {
      from_port = 7199
      to_port = 7199
      protocol = "tcp"
      security_groups = [aws_security_group.sg_internal_only.id]
   }

   # Port for inter-node messaging service
   ingress {
      from_port = 8609
      to_port = 8609
      protocol = "tcp"
      security_groups = [aws_security_group.sg_internal_only.id]
   }

   # DSE Search web access port
   ingress {
      from_port = 8983
      to_port = 8983
      protocol = "tcp"
      security_groups = [aws_security_group.sg_internal_only.id]
   }

   # Native transport port
   ingress {
      from_port = 9042
      to_port = 9042
      protocol = "tcp"
      security_groups = [aws_security_group.sg_internal_only.id]
   }

   # Native transport port, with SSL
   ingress {
      from_port = 9142
      to_port = 9142
      protocol = "tcp"
      security_groups = [aws_security_group.sg_internal_only.id]
   }

   # Client (Thrift) port
   ingress {
      from_port = 9160
      to_port = 9160
      protocol = "tcp"
      security_groups = [aws_security_group.sg_internal_only.id]
   }

   # Spark SQL Thrift server port
   ingress {
      from_port = 10000
      to_port = 10000
      protocol = "tcp"
      security_groups = [aws_security_group.sg_internal_only.id]
   }

   # Stomp port: opsc -> agent
   ingress {
      from_port = 61621
      to_port = 61621
      protocol = "tcp"
      security_groups = [aws_security_group.sg_internal_only.id]
   }
}

# associate route table with subnet
# resource "aws_route_table_association" "test_tf_a_rt" {
#  subnet_id      = aws_subnet.venmo_subnet.id
#  route_table_id = aws_route_table.venmo_rt.id
#}

# EC2 Instances for DSE 

resource "aws_instance" "dse" {
  ami = var.ami_id
  instance_type = var.instance_type[0]
  count = var.instance_count[0].count
  subnet_id = aws_subnet.venmo_subnet.id
  availability_zone = var.availability_zone
  associate_public_ip_address = true
  security_groups = [aws_security_group.sg_internal_only.id,aws_security_group.sg_ssh.id,aws_security_group.sg_dse_node.id]
  key_name = var.key_name

  tags = {
    Name = "venmo-${var.instance_count[0].name}-node-${count.index}"
  }

  user_data = data.template_file.user_data.rendered
}

# EC2 Instances for OPSC 

resource "aws_instance" "opsc" {
  ami = var.ami_id
  instance_type = var.instance_type[0]
  count = var.instance_count[1].count
  subnet_id = aws_subnet.venmo_subnet.id
  availability_zone = var.availability_zone
  associate_public_ip_address = true
  security_groups = [aws_security_group.sg_internal_only.id,aws_security_group.sg_ssh.id,aws_security_group.sg_opsc_web.id,aws_security_group.sg_opsc_node.id,aws_security_group.sg_dse_node.id]
  key_name = var.key_name

  tags = {
    Name = "venmo-${var.instance_count[1].name}-${count.index}"
  }

  user_data = data.template_file.user_data.rendered
}

data "template_file" "user_data" {
   template = <<-EOF
              #!/bin/bash
              apt-get update -y
              apt-get install python-minimal -y
              apt-get install ntp -y
              apt-get install ntpstat -y
              ntpq -pcrv
              
              # Raid 0 - Configuration 
              sudo mdadm --create --verbose /dev/md0 --level=0 --name=vol_venmo_raid --raid-devices=3 /dev/nvme0n1 /dev/nvme1n1 /dev/nvme2n1
              sudo mkfs.ext4 -L vol_venmo_raid /dev/md0
              sudo mdadm --detail --scan | sudo tee -a /etc/mdadm.conf
              sudo apt-get install dracut
              sudo dracut -H -f /boot/initramfs-$(uname -r).img $(uname -r)
              sudo mkdir -p /mnt/venmovol
              sudo mount LABEL=vol_venmo_raid /mnt/venmovol
              # Mount another drive
              mkfs.ext4 /dev/nvme3n1
              mkdir /mnt/nvme3n1
              mount /dev/nvme3n1 /mnt/nvme3n1
              echo "/dev/mod0 /mnt/venmovol ext4 noatime,data=writeback,barrier=0,nobh 0 0" | sudo cat >> /etc/fstab
              echo "/dev/nvme3n1 /mnt/nvme3n1 ext4 noatime,data=writeback,barrier=0,nobh 0 0" | sudo cat >> /etc/fstab
              mount -a
              EOF
}