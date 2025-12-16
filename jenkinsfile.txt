pipeline {
    agent any

    environment {
        DOCKER_IMAGE = "waelkhalfi/devops"     // DockerHub image
        DOCKER_CRED  = "docker-creds"          // Jenkins credentials ID for Docker (username + password)
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
                    sh "docker build -t ${DOCKER_IMAGE}:${tag} ."
                }
            }
        }

        stage('Docker Push') {
            steps {
                withCredentials([usernamePassword(credentialsId: "${DOCKER_CRED}", usernameVariable: 'DH_USER', passwordVariable: 'DH_PASS')]) {
                    script {
                        TAG = sh(script: 'git rev-parse --short HEAD', returnStdout: true).trim()
                        sh """
                            echo "$DH_PASS" | docker login -u "$DH_USER" --password-stdin
                            docker push ${DOCKER_IMAGE}:${TAG}
                            docker tag ${DOCKER_IMAGE}:${TAG} ${DOCKER_IMAGE}:latest
                            docker push ${DOCKER_IMAGE}:latest
                            docker logout
                        """
                    }
                }
            }
        }
    }

    post {
        success { echo "🎉 Pipeline succeeded: ${DOCKER_IMAGE}" }
        failure { echo "❌ Pipeline failed" }
    }
}
