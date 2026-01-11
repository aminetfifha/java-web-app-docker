pipeline {
    agent any

    stages {

        stage('SCM Checkout') {
            steps {
                git branch: 'main',
                    url: 'https://github.com/aminetfifha/java-web-app-docker.git'
            }
        }

        stage('Maven Build') {
            steps {
                sh 'mvn clean package'
            }
        }

        stage('Docker Build') {
            steps {
                sh 'docker build -t aminetfifha/java-web-app:1.0 .'
            }
        }

        stage('Docker Push') {
            steps {
                withCredentials([string(credentialsId: 'Docker_Hub_Pwd', variable: 'DOCKER_PWD')]) {
                    sh 'docker login -u aminetfifha -p $DOCKER_PWD'
                }
                sh 'docker push aminetfifha/java-web-app:1.0'
            }
        }

        stage('Deploy on Remote Server') {
            steps {
                sshagent(['DOCKER_SERVER']) {

                    sh 'ssh -o StrictHostKeyChecking=no amine@172.28.53.219 docker stop java-app || true'
                    sh 'ssh amine@172.28.53.219 docker rm java-app || true'
                    sh 'ssh amine@172.28.53.219 docker pull aminetfifha/java-web-app:1.0'
                    sh 'ssh amine@172.28.53.219 docker run -d -p 8080:8080 --name java-app aminetfifha/java-web-app:1.0'
                }
            }
        }
    }
}
