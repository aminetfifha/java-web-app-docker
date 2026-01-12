pipeline {
    agent any 
    
    tools {
        maven 'Maven3'  // à adapter si ton Maven s'appelle autrement dans Jenkins
    }

    environment {
        DOCKER_IMAGE_NAME = "docker00a/java-web-app"   // ton repo DockerHub
        DOCKER_TAG        = "${env.BUILD_NUMBER}"     // version par numéro de build
        PROD_SERVER       = "ubuntu@172.31.20.72"     // serveur de prod
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'master',
                    url: 'https://github.com/aminetfifha/java-web-app-docker.git'
            }
        }

        stage('Maven Build') {
            steps {
                sh 'mvn clean package'
                archiveArtifacts artifacts: 'target/*.war', fingerprint: true
            }
        }

        stage('Build & Tag Docker Image') {
            steps {
                sh "docker build -t ${DOCKER_IMAGE_NAME}:${DOCKER_TAG} ."
                sh "docker tag ${DOCKER_IMAGE_NAME}:${DOCKER_TAG} ${DOCKER_IMAGE_NAME}:latest"
            }
        }

        stage('Push Docker Image') {
            steps {
                // Connexion Docker avec token (PAT)
                sh """
                echo 'dckr_pat_VeoCPegbkfcalWuBYJogoqjbfN4' | docker login -u docker00a --password-stdin
                docker push ${DOCKER_IMAGE_NAME}:${DOCKER_TAG}
                docker push ${DOCKER_IMAGE_NAME}:latest
                docker logout
                """
            }
        }

        stage('Deploy to Production') {
            when {
                branch 'master'
            }
            steps {
                sshagent(credentials: ['prod-server-ssh-key']) {
                    sh """
                        ssh -o StrictHostKeyChecking=no ${PROD_SERVER} << EOF
                            docker stop java-web-app || true
                            docker rm java-web-app || true
                            docker pull ${DOCKER_IMAGE_NAME}:${DOCKER_TAG}
                            docker run -d --restart unless-stopped -p 8080:8080 --name java-web-app ${DOCKER_IMAGE_NAME}:${DOCKER_TAG}
                        EOF
                    """
                }
            }
        }
    }

    post {
        always {
            echo "Pipeline terminé - statut: ${currentBuild.currentResult}"
        }
        success {
            echo "Déploiement réussi ! 🎉"
        }
        failure {
            echo "Échec du pipeline 😞"
        }
    }
}
