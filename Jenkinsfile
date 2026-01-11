pipeline {
    agent any

    environment {
        // Variables DockerHub
        DOCKERHUB_REPO = "dockerhandson/java-web-app"
        DOCKER_IMAGE_TAG = "${BUILD_NUMBER}"
    }

    stages {
        stage('Checkout SCM') {
            steps {
                // Cloner le repo depuis GitHub
                git url: 'https://github.com/aminetfifha/java-web-app-docker.git', branch: 'master'
            }
        }

        stage('Maven Build') {
            tools {
                maven 'Maven3'  // Nom de ton Maven tool dans Jenkins
                jdk 'Java21'    // Nom de ton JDK 21 dans Jenkins
            }
            steps {
                // Nettoyer et compiler le projet + générer le WAR
                sh 'mvn clean package'
            }
        }

        stage('Archive WAR') {
            steps {
                // Archiver le fichier WAR généré
                archiveArtifacts artifacts: 'target/*.war', fingerprint: true
            }
        }

        stage('Build & Tag Docker Image') {
            steps {
                script {
                    // Construire l'image Docker avec le WAR
                    docker.build("${DOCKERHUB_REPO}:${DOCKER_IMAGE_TAG}", ".")
                }
            }
        }

        stage('Push Docker Image') {
            steps {
                script {
                    // Décommenter si tu veux push sur DockerHub
                    // docker.withRegistry('https://index.docker.io/v1/', 'dockerhub-credentials-id') {
                    //     docker.image("${DOCKERHUB_REPO}:${DOCKER_IMAGE_TAG}").push()
                    // }
                }
            }
        }
    }

    post {
        always {
            echo "Pipeline terminé !"
        }
        success {
            echo "Build réussi ✅"
        }
        failure {
            echo "Échec du pipeline 😞"
        }
    }
}

