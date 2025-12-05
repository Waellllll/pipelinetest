pipeline {
    agent any

    triggers {
        githubPush()
    }

    tools {
        jdk 'jdk17'
        maven 'maven3'
    }

    environment {
        REGISTRY = "waelkhalfi"          // DockerHub username
        IMAGE_NAME = "alpine"            // Image name in DockerHub
    }

    stages {

        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Build Maven') {
            steps {
                sh 'mvn clean install -DskipTests'
            }
        }

        stage('Docker Build') {
            steps {
                script {
                    dockerImage = docker.build("${REGISTRY}/${IMAGE_NAME}:${BUILD_NUMBER}")
                }
            }
        }

        stage('Docker Push') {
            steps {
                script {
                    docker.withRegistry('https://index.docker.io/v1/', 'docker-creds') {
                        dockerImage.push()
                        dockerImage.push("latest")
                    }
                }
            }
        }
    }

    post {
        success {
            echo "🎉 Pipeline successfully completed!"
        }
        failure {
            echo "❌ Pipeline failed."
        }
    }
}
