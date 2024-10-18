
## My personal End-to-End DevSecOps CI/CD Pipeline Setup

## Overview
Configuration and steps needed to build a custom CI/CD DevSecOps Jenkins pipeline and Github Actions pipeline.

## Dependencies
- An AWS EC2 VM running a Jenkins server with Trivy, Maven, Docker, Kubectl and Prometheus Node Exporter installed
- An AWS EC2 VM running a Github Actions Runner server with Docker, Maven, Trivy and Snyk hook
- An AWS EC2 VM running the Official Sonarqube container
- An AWS EC2 VM running the Official Nexus container
- An AWS EC2 VM running a Prometheus server with Grafana and Blackbox installed
- An AWS EC2 VM running Terraform server for EKS clusters
- An AWS EC2 VM running a Kubernetes Controller node
- An AWS EC2 VMs running Kubernetes Worker nodes
- An AWS EC2 VM running Ansible Controller


## Setup Instructions
1. **Terraform Main Setup**: Located in `main.tf`.
    - *IaC_setups.TXT*: Explains how to configure a VM with Terraform, AWS CLI, and Kubectl, from scratch.
    - Ansible server provisioning details.

2. **Security focused Pipeline Flow (may vary on Projects needs)**
   1. **Git Checkout**: Begin by checking out the code from your repository for Jenkin or Run off Github push COMMIT.
   2. **Maven Build and Test**: Compile the code and run unit tests using Maven.
   3. **OWASP Dependency Check**: Perform a security analysis of project dependencies with OWASP.
   4. **Snyk Check**: Conduct additional security checks using Snyk.
   5. **SonarQube Check**: Analyze the code quality using SonarQube.
   6. **Trivy Container Check**: Perform a security scan of container images using Trivy.
   7. **Docker Build and Push**: Build the Docker image and push it to your container registry.
   8. **Kubernetes Deployment**: Deploy the Docker image to your Kubernetes cluster.
       - EKS cluster setup details.
   9. **Prometheus and Grafana**: 
       - Set up Prometheus for monitoring your application.
       - Create Grafana dashboards to visualize metrics with Blackbox exporter.
    

## Notes
- For detailed steps on Terraform and Ansible setup, refer to `IaC_setups.TXT`.


