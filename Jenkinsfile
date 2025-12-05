pipeline {
    agent any

    environment {
        REGISTRY    = "waelkhalfi"          // DockerHub username
        IMAGE_NAME  = "alpine"              // Docker image name
        DOCKER_CRED = "docker-creds"        // Jenkins Docker credentials ID
        JAVA_HOME   = "/usr/lib/jvm/java-17-openjdk-amd64"
        PATH        = "${JAVA_HOME}/bin:${env.PATH}"
    }

    tools {
        jdk 'jdk17'       // Must match Jenkins Global Tool Configuration
        maven 'maven'     // Must match Jenkins Global Tool Configuration
    }

    stages {

        stage('Checkout') {
            steps {
                checkout scm
                script { 
                    echo "Branch: ${env.BRANCH_NAME ?: 'unknown'}" 
                }
            }
        }

        stage('Clean + Build Maven') {
            steps {
                sh '''
                  echo "JAVA_HOME=$JAVA_HOME"
                  java -version
                  mvn -B clean package -DskipTests=false
                '''
            }
            post {
                success {
                    archiveArtifacts artifacts: 'target/*.jar', fingerprint: true
                }
            }
        }

        stage('Unit Tests') {
            steps {
                sh 'mvn test'
            }
        }

        stage('Docker Build') {
            steps {
                script {
                    def tag = sh(script: 'git rev-parse --short HEAD', returnStdout: true).trim()
                    sh "docker build -t ${REGISTRY}/${IMAGE_NAME}:${tag} ."
                }
            }
        }

        stage('Docker Push') {
            steps {
                withCredentials([usernamePassword(credentialsId: "${DOCKER_CRED}", usernameVariable: 'DH_USER', passwordVariable: 'DH_PASS')]) {
                    script {
                        def tag = sh(script: 'git rev-parse --short HEAD', returnStdout: true).trim()
                        sh """
                            echo "$DH_PASS" | docker login -u "$DH_USER" --password-stdin
                            docker push ${REGISTRY}/${IMAGE_NAME}:${tag}
                            docker push ${REGISTRY}/${IMAGE_NAME}:latest
                            docker logout
                        """
                    }
                }
            }
        }
    }

    post {
        success { echo "🎉 Pipeline succeeded: ${REGISTRY}/${IMAGE_NAME}" }
        failure { echo "❌ Pipeline failed" }
    }
}
