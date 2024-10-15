variable "region" {
  description = "The AWS region to deploy to"
  default     = "us-east-2"  # Change this to your desired region
}

variable "vpc_cidr" {
  description = "The CIDR block for the VPC"
  default     = "10.0.0.0/16"  # Change this if needed
}

variable "public_subnet_cidrs" {
  description = "The CIDR blocks for the public subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]  # Change this if needed
}

variable "cluster_name" {
  description = "The name of the EKS cluster"
  default     = "aws_eks_cluster"  # Change this if needed
}
