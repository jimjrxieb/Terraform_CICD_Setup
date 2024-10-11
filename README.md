
# Comprehensive End-to-End DevSecOps Jenkins Pipeline Setup

## Overview
Configuration and steps needed to build a custom DevSecOps Jenkins pipeline.

## Dependencies
- Custom Jenkins container with Maven and Trivy (local)
- An AWS EC2 VM running the Official Sonarqube container
- An AWS EC2 VM running the Official Nexus container
- An AWS EC2 VM running the Official Prometheus container

## Prerequisites
Ensure the following tools and plugins are installed:
- Docker
- Jenkins
- Terraform
- AWS CLI
- Kubectl
- Snyk
- OWASP Dependency Check
- Trivy Container Scanner
- Splunk 

## Setup Instructions
1. **Terraform Main Setup**: Located in `main.tf`.
    - *EXTRASTEPS.TXT*: Steps to create a VM with Terraform, AWS CLI, and Kubectl, from scratch.
    - Ansible server provisioning details.

2. **Pipeline Flow**
   1. **Git Checkout**: Begin by checking out the code from your repository.
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
       - Create Grafana dashboards to visualize metrics.

## Notes
- For detailed steps on Terraform and Ansible setup, refer to `EXTRASTEPS.TXT`.


