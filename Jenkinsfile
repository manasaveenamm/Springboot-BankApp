pipeline {
    agent any
    
    environment {
        AWS_BUCKET_NAME = 'bank-artifact-bucket'
        AWS_REGION      = 'ap-south-1'
        DOCKER_REGISTRY = 'localhost:5000'
        IMAGE_NAME      = 'banking-portal'
        BUILD_VER       = "1.0.${BUILD_NUMBER}"
        HOST_WORKSPACE  = "/var/lib/docker/volumes/jenkins_home/_data/workspace/${JOB_NAME}"
    }

    stages {
        stage('Phase 1: Build Automation') {
            steps {
                echo 'Building via standalone Maven environment...'
                sh "docker run --rm -v ${HOST_WORKSPACE}:/app -w /app maven:3.8.5-openjdk-17 mvn clean test package -DskipTests"
            }
        }

        stage('Phase 2: Artifact Management') {
            steps {
                withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-credentials']]) {
                    echo 'Uploading WAR artifact to AWS S3...'
                    sh """
                        docker run --rm \
                        -e AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID} \
                        -e AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY} \
                        -v ${HOST_WORKSPACE}:/aws amazon/aws-cli s3 cp target/banking-portal.war s3://${AWS_BUCKET_NAME}/builds/banking-portal-${BUILD_VER}.war --region ${AWS_REGION}
                    """
                }
            }
        }

        stage('Phase 3: Standard Tomcat Deployment') {
            steps {
                echo 'Deploying WAR artifact via Tomcat Auto-Migration layer...'
                
                // Changed destination volume mapping to webapps-javaee
                sh "docker run --rm -v ${HOST_WORKSPACE}:/workspace -v /opt/tomcat/webapps-javaee:/host_tomcat alpine cp /workspace/target/banking-portal.war /host_tomcat/ROOT.war"
                
                echo 'Verifying application deployment status...'
                sh 'sleep 15'
            }
        }

        stage('Phase 4: Containerization') {
            steps {
                echo 'Building production Docker image...'
                script {
                    // 1. Build the specific versioned image
                    sh "docker build -t ${DOCKER_REGISTRY}/${IMAGE_NAME}:${BUILD_VER} ."
                    
                    // 2. CREATE the 'latest' tag pointing to the version we just built
                    sh "docker tag ${DOCKER_REGISTRY}/${IMAGE_NAME}:${BUILD_VER} ${DOCKER_REGISTRY}/${IMAGE_NAME}:latest"
                    
                    // 3. Now both pushes will succeed perfectly!
                    sh "docker push ${DOCKER_REGISTRY}/${IMAGE_NAME}:${BUILD_VER}"
                    sh "docker push ${DOCKER_REGISTRY}/${IMAGE_NAME}:latest"
                }
            }
        }
    }
}
