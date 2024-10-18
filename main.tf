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
/*
################################## TERRAFORM SETUP FOR EKS CLUSTER ############################

resource "aws_instance" "terraform_instance" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t2.large"
  key_name               = var.key_name
  vpc_security_group_ids = var.vpc_security_group_ids
  tags                   = merge(var.tags, { Name = "Terraform" })

  provisioner "remote-exec" {
    inline = [
      "sudo apt update",
      "sudo snap install terraform --classic -y",
      "sudo apt update",
      "sudo snap install kubectl --classic -y",
      "sudo apt update",
      "curl \"https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip\" -o \"awscliv2.zip\"",
      "unzip awscliv2.zip",
      "sudo ./aws/install -y",
      "sudo apt update && sudo apt upgrade -y"
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
      "wget https://github.com/prometheus/prometheus/releases/download/v3.0.0-beta.1/prometheus-3.0.0-beta.1.linux-amd64.tar.gz",
      "sudo apt-get install -y adduser libfontconfig1",
      "wget https://dl.grafana.com/enterprise/release/grafana-enterprise_11.2.2+security~01_amd64.deb",
      "sudo dpkg -i grafana-enterprise_11.2.2+security~01_amd64.deb",
      "sudo /bin/systemctl start grafana-server",
      "wget https://github.com/prometheus/blackbox_exporter/releases/download/v0.25.0/blackbox_exporter-0.25.0.linux-amd64.tar.gz"
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
      "sudo chmod 666 /var/run/docker.sock",
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
/*
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
      "sudo chmod 666 /var/run/docker.sock",
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
*/
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
      "sudo apt install -y kubeadm kubelet kubectl",
      "sudo kubeadm init --pod-network-cidr=10.244.0.0/16"
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

################################ Github Actions Runner ##################################

resource "aws_instance" "runner_instance" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t2.large"
  key_name               = var.key_name
  vpc_security_group_ids = var.vpc_security_group_ids
  tags                   = merge(var.tags, { Name = "GH_runner" })

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update -y",
      "sudo apt-get install -y docker.io",
      "sudo chmod 666 /var/run/docker.sock",
      "sudo systemctl start docker",
      "sudo systemctl enable docker",
      "docker run -d --name SonarQube -p 9000:9000 sonarqube:lts-community",
      "sudo apt install maven -y",
      "sudo apt-get install wget apt-transport-https gnupg lsb-release",
      "wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key | sudo apt-key add -",
      "echo deb https://aquasecurity.github.io/trivy-repo/deb $(lsb_release -sc) main | sudo tee -a /etc/apt/sources.list.d/trivy.list",
      "sudo apt-get update",
      "sudo apt-get install trivy"
    ]

    connection {
      type        = "ssh"
      user        = var.ssh_user
      private_key = file(var.private_key_path)
      host        = self.public_ip
    }
  }
}

######################################## JENKINS ########################################
/*
resource "aws_instance" "jenkins_instance" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t2.large"
  key_name               = var.key_name
  vpc_security_group_ids = var.vpc_security_group_ids
  tags                   = merge(var.tags, { Name = "Jenkins" })

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update -y",
      "sudo apt-get install -y docker.io",
      "sudo chmod 666 /var/run/docker.sock",
      "sudo systemctl start docker",
      "sudo systemctl enable docker"     
      
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
      "sudo apt update",
      "sudo apt install ansible -y",
      "sudo apt-add-repository ppa:ansible/ansible -y",
      "sudo apt update && apt upgrade -y"
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
    #nexus      = "${aws_instance.nexus_instance.public_ip}:8081"
    prometheus = "${aws_instance.prometheus_instance.public_ip}:9090"
    #jenkins    = "${aws_instance.jenkins_instance.public_ip}:8080"
    k8s_master = "${aws_instance.k8s_master.public_ip}:6443"
    k8s_worker_1 = "${aws_instance.k8s_worker[0].public_ip}"
    k8s_worker_2 = "${aws_instance.k8s_worker[1].public_ip}"
    #ansible    = "${aws_instance.ansible_instance.public_ip}:22"
    #terraform  = "${aws_instance.terraform_instance.public_ip}:22"
  }
}

