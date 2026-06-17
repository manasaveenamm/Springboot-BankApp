pipeline {
    agent any
    
    environment {
        AWS_BUCKET_NAME = 'bank-artifact-bucket'
        AWS_REGION      = 'ap-south-1'
        TARGET_EC2_IP   = '13.233.162.252 '// Since everything is running locally on this instance
        TOMCAT_USER     = 'ubuntu'
        DOCKER_REGISTRY = 'localhost:5000'
        IMAGE_NAME      = 'banking-portal'
        BUILD_VER       = "1.0.${BUILD_NUMBER}"
    }
    
    tools {
        maven 'Maven 3.8.5'
    }

    stages {
        stage('Phase 1: Build Automation') {
            steps {
                sh 'mvn clean test package -Dbuild.version=${BUILD_VER}'
            }
        }

        stage('Phase 2: Artifact Management') {
            steps {
                withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-credentials']]) {
                    sh "aws s3 cp target/banking-portal.war s3://${AWS_BUCKET_NAME}/builds/banking-portal-${BUILD_VER}.war --region ${AWS_REGION}"
                }
            }
        }

        stage('Phase 3: Standard Tomcat Deployment') {
            steps {
                // Since Tomcat is on the SAME instance as Jenkins, copy files locally
                sh "sudo systemctl stop tomcat"
                sh "sudo rm -rf /opt/tomcat/webapps/ROOT*"
                sh "sudo cp target/banking-portal.war /opt/tomcat/webapps/ROOT.war"
                sh "sudo systemctl start tomcat"
                sh "sleep 15"
                sh 'curl -sI http://localhost:8080/ | grep "200 OK"'
            }
        }

        stage('Phase 4: Containerization') {
            steps {
                script {
                    sh "docker build -t ${DOCKER_REGISTRY}/${IMAGE_NAME}:${BUILD_VER} ."
                    sh "docker push ${DOCKER_REGISTRY}/${IMAGE_NAME}:${BUILD_VER}"
                    sh "docker push ${DOCKER_REGISTRY}/${IMAGE_NAME}:latest"
                }
            }
        }
    }
}
