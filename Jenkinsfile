pipeline {
    agent any

    triggers {
        // Déclenchement automatique lors d’un push Git (via webhook GitHub/GitLab)
        githubPush()
    }

    environment {
        REGISTRY = "votre-registry.com/votre-projet"   // Changez selon votre registre Docker
        IMAGE_NAME = "mon-application"
    }

    stages {

        stage('Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/votre-user/votre-repo.git'
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
