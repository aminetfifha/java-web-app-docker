pipeline {
    agent any 
    
    tools {
        maven 'Maven3'  // Change selon ton Maven configuré dans Jenkins
        // jdk 'JDK21'  // Décommente si nécessaire
    }

    environment {
        DOCKER_IMAGE_NAME = "docker00a/java-web-app"  // Ton nom DockerHub
        DOCKER_TAG        = "${env.BUILD_NUMBER}"     // Version par numéro de build
        PROD_SERVER       = "ubuntu@172.31.20.72"     // Ton serveur de prod
        DOCKER_USER       = "docker00a"               // Ton DockerHub username
        DOCKER_PASS       = "dckr_pat_VeoCPegbkfcalWuBYJogoqjbfN4"  // Ton DockerHub token
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
                
                archiveArtifacts artifacts: 'target/java-web-app*.war', 
                                 fingerprint: true,
                                 allowEmptyArchive: false
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
                sh """
                echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin
                docker push ${DOCKER_IMAGE_NAME}:${DOCKER_TAG}
                docker push ${DOCKER_IMAGE_NAME}:latest
                docker logout
                """
            }
        }

        stage('Deploy to Production') {
            steps {
                sshagent(credentials: ['prod-server-ssh-key']) {  // Clé SSH pour le serveur de prod
                    sh """
                        ssh -o StrictHostKeyChecking=no ${PROD_SERVER} << EOF
                            docker stop java-web-app || true
                            docker rm java-web-app || true
                            
                            docker pull ${DOCKER_IMAGE_NAME}:${DOCKER_TAG}
                            
                            docker run -d --restart unless-stopped \\
                                -p 8080:8080 \\
                                --name java-web-app \\
                                ${DOCKER_IMAGE_NAME}:${DOCKER_TAG}
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
