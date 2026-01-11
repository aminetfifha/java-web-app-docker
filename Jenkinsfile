pipeline {
    agent any 
    
    // Déclaration des outils nécessaires (doivent exister dans Global Tool Configuration)
    tools {
        maven 'Maven3'          // ← Change ce nom selon ce que tu as configuré dans Jenkins → Tools
        // jdk 'JDK17'          // décommente si tu as configuré un JDK spécifique
    }

    environment {
        // Variables globales utiles
        DOCKER_IMAGE_NAME = "dockerhandson/java-web-app"   // ← change par ton nom DockerHub
        DOCKER_TAG        = "${env.BUILD_NUMBER}"           // versionnement par numéro de build
        PROD_SERVER       = "ubuntu@172.31.20.72"           // ← ton serveur de prod
    }

    stages {
        
        stage('Checkout') {
            steps {
                git branch: 'master',
                    url: 'https://github.com/aminetfifha/java-web-app-docker.git',
                    credentialsId: 'github-pat'   // ← ton credential HTTPS PAT
            }
        }

        stage('Maven Build') {
    steps {
        sh 'mvn clean package'
        
        // Archive le fichier WAR généré
        archiveArtifacts artifacts: 'target/java-web-app-*.war', 
                         fingerprint: true,
                         allowEmptyArchive: false  // false = échec si le fichier n'existe pas
    }
}

        stage('Build & Tag Docker Image') {
            steps {
                sh "docker build -t ${DOCKER_IMAGE_NAME}:${DOCKER_TAG} ."
                sh "docker tag ${DOCKER_IMAGE_NAME}:${DOCKER_TAG} ${DOCKER_IMAGE_NAME}:latest"
            }
        }

        stage('Push Docker Image') {
            when {
                branch 'master'   // on push uniquement sur master (sécurité)
            }
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'dockerhub-credentials',
                    usernameVariable: 'DOCKER_USER',
                    passwordVariable: 'DOCKER_PASS'
                )]) {
                    sh 'echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin'
                    sh "docker push ${DOCKER_IMAGE_NAME}:${DOCKER_TAG}"
                    sh "docker push ${DOCKER_IMAGE_NAME}:latest"
                }
            }
        }

        stage('Deploy to Production') {
            when {
                branch 'master'
            }
            steps {
                sshagent(credentials: ['prod-server-ssh-key']) {   // ← credential SSH recommandé
                    sh """
                        ssh -o StrictHostKeyChecking=no ${PROD_SERVER} << EOF
                            docker stop java-web-app || true
                            docker rm java-web-app || true
                            # Optionnel : nettoyer les anciennes images (attention en prod !)
                            # docker rmi \$(docker images -q ${DOCKER_IMAGE_NAME}) || true
                            
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
            // Nettoyage léger (optionnel)
            sh 'docker logout || true'
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

