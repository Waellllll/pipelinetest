pipeline {
    agent any

    environment {
        DOCKER_IMAGE = "waelkhalfi/alpine"
        DOCKER_TAG   = "${env.GIT_COMMIT.take(7)}"
        JAVA_HOME    = "/usr/lib/jvm/java-17-openjdk-amd64"
        PATH         = "${JAVA_HOME}/bin:${env.PATH}"
    }

    stages {
        stage('Checkout SCM') {
            steps {
                checkout scm
                script { echo "Branch: ${env.BRANCH_NAME ?: 'unknown'}" }
            }
        }

        stage('Clean + Build Maven') {
            tools {
                maven 'Maven' // Make sure 'Maven' tool is configured in Jenkins
            }
            steps {
                sh '''
                    echo "JAVA_HOME=${JAVA_HOME}"
                    java -version
                    mvn -B clean package -DskipTests=false
                '''
                archiveArtifacts artifacts: 'target/*.jar', fingerprint: true
            }
        }

        stage('Unit Tests') {
            tools {
                maven 'Maven'
            }
            steps {
                sh 'mvn test'
            }
        }

        stage('Docker Build') {
            steps {
                script {
                    sh '''
                        docker build -t ${DOCKER_IMAGE}:${DOCKER_TAG} .
                    '''
                }
            }
        }

        stage('Docker Push') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'docker-creds', 
                    usernameVariable: 'DH_USER', 
                    passwordVariable: 'DH_PASS'
                )]) {
                    sh '''
                        echo $DH_PASS | docker login -u $DH_USER --password-stdin
                        docker push ${DOCKER_IMAGE}:${DOCKER_TAG}
                    '''
                }
            }
        }
    }

    post {
        success {
            echo "✅ Pipeline completed successfully"
        }
        failure {
            echo "❌ Pipeline failed"
        }
    }
}
