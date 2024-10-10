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

output "instance_ips" {
  value = {
    sonarqube  = "${aws_instance.sonarqube_instance.public_ip}:9000"
    nexus      = "${aws_instance.nexus_instance.public_ip}:8081"
    prometheus = "${aws_instance.prometheus_instance.public_ip}:9090"
  }
}
