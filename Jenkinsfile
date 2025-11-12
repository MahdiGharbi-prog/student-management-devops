pipeline {
    agent any

    options {
        buildDiscarder(logRotator(numToKeepStr: '5'))
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('SonarQube Scan') {
            steps {
                // On se place dans le dossier du projet où se trouve mvnw
                dir('student-man-main') {
                    // Injection des variables SonarQube configurées dans Jenkins
                    withSonarQubeEnv(installationName: 'SonarQube') {
                        // On précise explicitement l'URL du serveur SonarQube
                        sh './mvnw clean org.sonarsource.scanner.maven:sonar-maven-plugin:3.9.0.2155:sonar -Dsonar.host.url=http://localhost:32000'
                    }
                }
            }
        }
    }
}
