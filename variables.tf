variable "region" {
  description = "The AWS region to deploy to"
  default     = "us-east-1"
}

variable "ami_owner" {
  description = "The owner ID of the AMI"
  default     = "099720109477"
}

variable "ami_name_filter" {
  description = "The name filter for the AMI"
  default     = "ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"
}

variable "instance_type" {
  description = "The type of instance to use"
  default     = "t2.medium"
}

variable "key_name" {
  description = "The name of the key pair to use"
  default     = "MobaTermKey"
}

variable "vpc_security_group_ids" {
  description = "The security group IDs to associate with the instance"
  type        = list(string)
  default     = ["sg-0767adb689f42d116"]
}

variable "tags" {
  description = "Tags to apply to the instance"
  type        = map(string)
  default     = {}
}

variable "ssh_user" {
  description = "The SSH user to connect as"
  default     = "ubuntu"
}

variable "private_key_path" {
  description = "The path to the private key file"
  default     = "~/.ssh/MobaTermKey.pem"
}
