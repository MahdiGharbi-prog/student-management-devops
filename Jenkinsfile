pipeline {
    agent any

    environment {
        // Nom du serveur SonarQube configuré dans Jenkins
        SONARQUBE = 'SonarQube'
    }

    stages {
        stage('Checkout') {
            steps {
                git url: 'https://github.com/ghaithelbenna/student-management-devops.git', branch: 'master'
            }
        }

        stage('Build') {
            steps {
                dir('student-man-main') {
                    sh 'chmod +x mvnw'
                    sh './mvnw clean install -DskipTests'
                }
            }
        }

        stage('SonarQube Analysis') {
            steps {
                dir('student-man-main') {
                   withSonarQubeEnv(installationName: 'SonarQube'){
                              sh './mvnw sonar:sonar -Dsonar.java.binaries=target/classes'                    }
                }
            }
        }

        stage('Quality Gate') {
            steps {
                // Timeout pour éviter que le pipeline bloque trop longtemps
                timeout(time: 30, unit: 'MINUTES') {
                    waitForQualityGate abortPipeline: true
                }
            }
        }
    }
}
