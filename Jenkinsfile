pipeline {
    agent any

    environment {
        // Docker
        DOCKER_IMAGE = "waelkhalfi/devops"
        DOCKER_CRED  = "docker-creds"

        // SonarQube
        SONAR_TOKEN     = credentials('sonar-token')
        SONAR_HOST_URL  = 'http://192.168.33.10:9000'
    }

    tools {
        jdk 'jdk17'
        maven 'maven'
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
                    mvn -B clean package
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

        stage('SonarQube Analysis') {
            steps {
                sh """
                mvn sonar:sonar \
                  -Dsonar.host.url=${SONAR_HOST_URL} \
                  -Dsonar.login=${SONAR_TOKEN}
                """
            }
        }

        stage('Docker Build') {
            steps {
                script {
                    TAG = sh(script: 'git rev-parse --short HEAD', returnStdout: true).trim()
                    sh "docker build -t ${DOCKER_IMAGE}:${TAG} ."
                }
            }
        }

        stage('Docker Push') {
            steps {
                withCredentials([
                    usernamePassword(
                        credentialsId: DOCKER_CRED,
                        usernameVariable: 'DH_USER',
                        passwordVariable: 'DH_PASS'
                    )
                ]) {
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

    post {
        success {
            echo "🎉 Pipeline succeeded"
            echo "🐳 Docker image pushed: ${DOCKER_IMAGE}"
        }
        failure {
            echo "❌ Pipeline failed"
        }
    }
}
