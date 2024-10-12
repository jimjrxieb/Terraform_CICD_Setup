provider "aws" {
  region = var.region
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = [var.ami_owner]
  filter {
    name   = "name"
    values = [var.ami_name_filter]
  }
}

################################## TERRAFORM SETUP FOR EKS CLUSTER ############################

resource "aws_instance" "terraform_instance" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t2.large"
  key_name               = var.key_name
  vpc_security_group_ids = var.vpc_security_group_ids
  tags                   = merge(var.tags, { Name = "Terraform" })

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update -y",
      "sudo snap install terraform --classic",
      "sudo apt-get update",
      "sudo snap install kubectl --classic",
      "sudo apt-get update",
      "sudo apt  install awscli -y",
      "sudo apt install unzip",
      "sudo apt-get update -y"
    ]

    connection {
      type        = "ssh"
      user        = var.ssh_user
      private_key = file(var.private_key_path)
      host        = self.public_ip
    }
  }
}

######################################## Monitoring ########################################

resource "aws_instance" "prometheus_instance" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  key_name               = var.key_name
  vpc_security_group_ids = var.vpc_security_group_ids
  tags                   = merge(var.tags, { Name = "Prometheus" })

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update -y",
      "sudo apt-get install -y docker.io",
      "sudo apt-get update -y",
      "sudo systemctl start docker",
      "sudo systemctl enable docker",
      "sudo docker run -d --name prometheus -p 9090:9090 prom/prometheus"
    ]

    connection {
      type        = "ssh"
      user        = var.ssh_user
      private_key = file(var.private_key_path)
      host        = self.public_ip
    }
  }
}

######################################## SONARQUBE ########################################

resource "aws_instance" "sonarqube_instance" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  key_name               = var.key_name
  vpc_security_group_ids = var.vpc_security_group_ids
  tags                   = merge(var.tags, { Name = "SonarQube" })

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update -y",
      "sudo apt-get install -y docker.io",
      "sudo apt-get update -y",
      "sudo systemctl start docker",
      "sudo systemctl enable docker",
      "sudo docker run -d --name sonarqube -p 9000:9000 sonarqube"
    ]

    connection {
      type        = "ssh"
      user        = var.ssh_user
      private_key = file(var.private_key_path)
      host        = self.public_ip
    }
  }
}

######################################## NEXUS ########################################

resource "aws_instance" "nexus_instance" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  key_name               = var.key_name
  vpc_security_group_ids = var.vpc_security_group_ids
  tags                   = merge(var.tags, { Name = "Nexus" })

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update -y",
      "sudo apt-get install -y docker.io",
      "sudo apt-get update -y",
      "sudo systemctl start docker",
      "sudo systemctl enable docker",
      "sudo docker run -d --name nexus -p 8081:8081 sonatype/nexus3"
    ]

    connection {
      type        = "ssh"
      user        = var.ssh_user
      private_key = file(var.private_key_path)
      host        = self.public_ip
    }
  }
}

######################################## Kubernetes ########################################

resource "aws_instance" "k8s_master" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  key_name               = var.key_name
  vpc_security_group_ids = var.vpc_security_group_ids
  tags                   = merge(var.tags, { Name = "K8_Master" })

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update -y",
      "sudo apt-get install -y docker.io",
      "sudo chmod 666 /var/run/docker.sock",
      "sudo apt-get install -y apt-transport-https ca-certificates curl gnupg",
      "sudo mkdir -p -m 755 /etc/apt/keyrings",
      "curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.28/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg",
      "echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.28/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list",
      "sudo apt update -y",
      "sudo apt install -y kubeadm kubelet kubectl"
    ]

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file(var.private_key_path)
      host        = self.public_ip
    }
  }
}

######################################## Kubernetes Slaves ########################################

resource "aws_instance" "k8s_worker" {
  count                  = 2
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  key_name               = var.key_name
  vpc_security_group_ids = var.vpc_security_group_ids
  tags = merge(var.tags, { Name = "K8_Worker_${count.index + 1}" })

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update -y",
      "sudo apt-get install -y docker.io",
      "sudo chmod 666 /var/run/docker.sock",
      "sudo apt-get install -y apt-transport-https ca-certificates curl gnupg",
      "sudo mkdir -p -m 755 /etc/apt/keyrings",
      "curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.28/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg",
      "echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.28/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list",
      "sudo apt update -y",
      "sudo apt install -y kubeadm kubelet kubectl"
    ]

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file(var.private_key_path)
      host        = self.public_ip
    }
  }
}


######################################## JENKINS ########################################
/*
resource "aws_instance" "jenkins_instance" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  key_name               = var.key_name
  vpc_security_group_ids = var.vpc_security_group_ids
  tags                   = merge(var.tags, { Name = "Jenkins" })

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update -y",
      "sudo apt-get install -y docker.io",
      "sudo systemctl start docker",
      "sudo systemctl enable docker",
      "sudo docker run -d --name Jenkins -p 8080:8080 linksrobot/my-jenkins:v3.0"
    ]

    connection {
      type        = "ssh"
      user        = var.ssh_user
      private_key = file(var.private_key_path)
      host        = self.public_ip
    }
  }
}

######################################## ANSIBLE ########################################

resource "aws_instance" "ansible_instance" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  key_name               = var.key_name
  vpc_security_group_ids = var.vpc_security_group_ids
  tags                   = merge(var.tags, { Name = "Ansible" })

  provisioner "remote-exec" {
    inline = [
      "sudo apt update && apt upgrade -y",
      "sudo apt install ansible -y",
      "sudo apt-add-repository ppa:ansible/ansible -y",
      "sudo apt update"
    ]

    connection {
      type        = "ssh"
      user        = var.ssh_user
      private_key = file(var.private_key_path)
      host        = self.public_ip
    }
  }
}
*/
######################################## OUTPUT ######################################## 

output "instance_ips" {
  value = {
    sonarqube  = "${aws_instance.sonarqube_instance.public_ip}:9000"
    nexus      = "${aws_instance.nexus_instance.public_ip}:8081"
    prometheus = "${aws_instance.prometheus_instance.public_ip}:9090"
    #jenkins    = "${aws_instance.jenkins_instance.public_ip}:8080"
    #ansible    = "${aws_instance.ansible_instance.public_ip}:22"
    terraform  = "${aws_instance.terraform_instance.public_ip}:22"
  }
}
