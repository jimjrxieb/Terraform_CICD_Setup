pipeline {
    agent any
    tools {
        jdk "jdk17"
        maven "maven3"
    }
    
    environment {
        SCANNER_HOME= tool 'sonar-scanner'
    }

    stages {
        stage('Git Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/jimjrxieb/DSO_Boardgame.git'
            }
        }
        
        
        stage('Compile') {
            steps {
                sh 'mvn compile'
            }
        }
       
        stage('OWASP SCAN') {
            steps {
                dependencyCheck additionalArguments: '', odcInstallation: 'DP-check'
                dependencyCheckPublisher pattern: '**/dependency-check-report.xml'
            }
        }
    
        stage('Test') {
            steps {
                sh 'mvn test'
            }
        }
        
        stage('Trivy FS Scan') {
            steps {
                sh "trivy fs --format table -o fs-report.html ."
            }
        }
        
        stage('SonarQube Analysis') {
            steps {
                withSonarQubeEnv('sonar-server'){
                   sh ''' $SCANNER_HOME/bin/sonar-scanner -Dsonar.projectName=Devops-CICD \
                   -Dsonar.java.binaries=. \
                   -Dsonar.projectKey=Devops-CICD '''
                }
            }
        }
        
        stage('Build') {
            steps {
                sh 'mvn package'
            }
        }
    
        stage('COPY MORE') {
            steps {
                echo 'Hello World'
            }
        }
    }
}
        
    stage('Publish OWASP Dependency Check Report') {
      steps {
        publishHTML(target: [
          allowMissing: false,
          alwaysLinkToLastBuild: true,
          keepAll: true,
          reportDir: 'target',
          reportFiles: 'dependency-check-report.html',
          reportName: 'OWASP Dependency Check Report'
        ])
      }
    }
    stage('Publish Artifacts') {
      steps {
        withMavenSettings(mavenSettingsConfig: 'globalmavensettings') {  // # Ensure the correct Maven settings
          sh 'mvn deploy'
        }
      }
    }
    stage('Docker Build & Tag') {
      steps {
        script {
          withDockerRegistry(credentialsId: 'docker-cred') {  // # Ensure the correct Docker registry credentials
            sh 'docker build -t your-image-name:latest .'  // # Update Docker image name and tag
          }
        }
      }
    }
    stage('Trivy Image Scan') {
      steps {
        sh 'trivy image --format table -o image.html your-image-name:latest'  // # Ensure Trivy is installed and configured
      }
    }
    stage('Docker Push Image') {
      steps {
        script {
          withDockerRegistry(credentialsId: 'docker-cred') {  // # Ensure the correct Docker registry credentials
            sh 'docker push your-image-name:latest'  // # Update Docker image name and tag
          }
        }
      }
    }
    stage('Deploy to Kubernetes') {
      steps {
        script {
          withKubeConfig([credentialsId: 'kubeconfig-cred', serverUrl: 'https://your-k8s-cluster-url']) {  // # Ensure the correct Kubernetes config and server URL
            sh 'kubectl apply -f k8s/deployment.yaml'  // # Ensure the correct path to your Kubernetes deployment YAML
            sh 'kubectl apply -f k8s/service.yaml'  // # Ensure the correct path to your Kubernetes service YAML
          }
        }
      }
    }

    stage('Verify the Deployment') {
      steps {
        withKubeConfig(caCertificate: '', clusterName: 'kubernetes', contextName: '', credentialsId: 'k8-cred', namespace: 'webapps', restrictKubeConfigAccess: false, serverUrl: 'https://172.31.8.146:6443') {
          sh "kubectl get pods -n webapps"
          sh "kubectl get svc -n webapps"
        }
      }
    }
  }
}

# Key Notes:
# Git Checkout: Update the repository URL and credentials.
# SonarQube Analysis: Change the sonar.projectName and sonar.projectKey.
# Docker Build & Tag: Update the image name and tag.
# Docker Push Image: Ensure the image name and tag match the build stage.
# Kubernetes Deployment: Ensure the Kubernetes configuration and YAML paths are correct.
