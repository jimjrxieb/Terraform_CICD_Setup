provider "aws" {
  region = "us-east-1"
}
# Custom Jenkins Server
resource "aws_instance" "jenkins" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t2.large"
  key_name               = "MobaTermKey" # Use your key pair name 
  vpc_security_group_ids = ["sg-0767adb689f42d116"]
  tags = {
    Name = "Jenkins"
  }

  provisioner "remote-exec" {
    inline = [
      "set -ex",
      "sudo apt-get update",
      "sudo apt-get install -y docker.io",
      "sudo systemctl start docker",
      "sudo systemctl enable docker",
      "sudo docker run -d --name jenkins -p 8080:8080 linksrobot/my-jenkins:v2.0",

    ]

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("~/.ssh/MobaTermKey.pem")
      host        = self.public_ip
    }
  }
}

# SonarQube Server
resource "aws_instance" "sonarqube" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t2.medium"
  key_name               = "MobaTermKey"
  vpc_security_group_ids = ["sg-0767adb689f42d116"]
  tags = {
    Name = "SonarQube"
  }

  provisioner "remote-exec" {
    inline = [
      "set -ex",
      "sudo apt-get update",
      "sudo apt-get install -y docker.io",
      "sudo systemctl start docker",
      "sudo systemctl enable docker",
      "sudo docker run -d --name sonar -p 9000:9000 sonarqube"
    ]

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("~/.ssh/MobaTermKey.pem")
      host        = self.public_ip
    }
  }
}

# Nexus Server
resource "aws_instance" "nexus" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t2.medium"
  key_name               = "MobaTermKey"
  vpc_security_group_ids = ["sg-0767adb689f42d116"]
  tags = {
    Name = "Nexus"
  }

  provisioner "remote-exec" {
    inline = [
      "set -ex",
      "sudo apt-get update",
      "sudo apt-get install -y docker.io",
      "sudo systemctl start docker",
      "sudo systemctl enable docker",
      "sudo docker run -d --name nexus -p 8081:8081 sonatype/nexus3"
    ]

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("~/.ssh/MobaTermKey.pem")
      host        = self.public_ip
    }
  }
}

resource "aws_instance" "monitoring" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t2.medium"
  key_name               = "MobaTermKey"
  vpc_security_group_ids = ["sg-0767adb689f42d116"]
  tags = {
    Name = "Monitoring"
  }

  provisioner "remote-exec" {
    inline = [
      "set -ex",
      "sudo apt-get update",
      "sudo apt-get install -y docker.io",
      "sudo systemctl start docker",
      "sudo systemctl enable docker",
      # Install Prometheus
      "sudo docker run -d -p 9090:9090 --name prometheus prom/prometheus",
      # Install Grafana
      "sudo docker run -d -p 3000:3000 --name grafana grafana/grafana"
    ]

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("~/.ssh/MobaTermKey.pem")
      host        = self.public_ip
    }
  }
}

resource "aws_instance" "k8s_master" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t2.medium"
  key_name               = "MobaTermKey"
  vpc_security_group_ids = ["sg-0767adb689f42d116"]
  tags = {
    Name = "k8s-master"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update",
      "sudo apt install docker.io -y",
      "sudo chmod 666 /var/run/docker.sock",
      "sudo apt-get install -y apt-transport-https ca-certificates curl gnupg",
      "sudo mkdir -p -m 755 /etc/apt/keyrings",
      "curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.28/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg",
      "echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.28/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list",
      "sudo apt update",
      "sudo apt install -y kubeadm=1.28.1-1.1 kubelet=1.28.1-1.1 kubectl=1.28.1-1.1",
      "sudo kubeadm init --pod-network-cidr=10.244.0.0/16",
      "mkdir -p $HOME/.kube",
      "sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config",
      "sudo chown $(id -u):$(id -g) $HOME/.kube/config",
      "kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml"
    ]

    connection {
      type        = "ssh"
      user        = "ubuntu" # Replace with your instance's user
      private_key = file("~/.ssh/MobaTermKey.pem")
      host        = self.public_ip
    }
  }
}

resource "aws_instance" "k8s_worker" {
  count                  = 2
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t2.medium"
  key_name               = "MobaTermKey"
  vpc_security_group_ids = ["sg-0767adb689f42d116"]
  tags = {
    Name = "k8s-worker-${count.index + 1}"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update",
      "sudo apt install docker.io -y",
      "sudo chmod 666 /var/run/docker.sock",
      "sudo apt-get install -y apt-transport-https ca-certificates curl gnupg",
      "sudo mkdir -p -m 755 /etc/apt/keyrings",
      "curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.28/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg",
      "echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.28/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list",
      "sudo apt update",
      "sudo apt install -y kubeadm=1.28.1-1.1 kubelet=1.28.1-1.1 kubectl=1.28.1-1.1",
      "sudo kubeadm init --pod-network-cidr=10.244.0.0/16",
      "mkdir -p $HOME/.kube",
      "sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config",
      "sudo chown $(id -u):$(id -g) $HOME/.kube/config",
      "kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml"
    ]

    connection {
      type        = "ssh"
      user        = "ubuntu" # Replace with your instance's user
      private_key = file("~/.ssh/MobaTermKey.pem")
      host        = self.public_ip
    }
  }
}


data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
}

output "instance_ips" {
  value = {
    jenkins     = aws_instance.jenkins.public_ip
    sonarqube   = aws_instance.sonarqube.public_ip
    nexus       = aws_instance.nexus.public_ip
    monitoring  = aws_instance.monitoring.public_ip
    k8s_master  = aws_instance.k8s_master.public_ip
    k8s_worker1 = aws_instance.k8s_worker[0].public_ip
    k8s_worker2 = aws_instance.k8s_worker[1].public_ip
  }
}

