pipeline {
    agent any

    triggers {
        // Déclenchement automatique lors d’un push Git (via webhook GitHub/GitLab)
        githubPush()
    }

    environment {
        REGISTRY = "waelkhalfi/alpine"   // Changez selon votre registre Docker
        IMAGE_NAME = "alpine"
    }

    stages {

        stage('Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/Waellllll/pipelinetest.git'
            }
        }

        stage('Clean') {
            steps {
                sh 'mvn clean'         // Exemple pour un projet Maven
                // ou : sh 'rm -rf build/*'
            }
        }

        stage('Build') {
            steps {
                sh 'mvn package'       // Ou la commande adaptée à votre projet
            }
        }

        stage('Docker Build') {
            steps {
                sh """
                    docker build -t ${REGISTRY}/${IMAGE_NAME}:latest .
                """
            }
        }

        stage('Docker Push') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'docker-creds',
                                                  usernameVariable: 'DOCKER_USER',
                                                  passwordVariable: 'DOCKER_PASS')]) {

                    sh """
                        echo "$DOCKER_PASS" | docker login $REGISTRY -u "$DOCKER_USER" --password-stdin
                        docker push ${REGISTRY}/${IMAGE_NAME}:latest
                        docker logout
                    """
                }
            }
        }
    }

    post {
        success {
            echo "Build & Push successfully completed!"
        }
        failure {
            echo "Pipeline failed."
        }
    }
}
