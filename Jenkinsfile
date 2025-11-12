pipeline {
    agent any

    options {
        buildDiscarder(logRotator(numToKeepStr: '5'))
    }

    stages {
        stage('Scan') {
            steps {
                dir('student-man-main') { // se déplacer dans le dossier du projet
                    withSonarQubeEnv(installationName: 'SonarQube') {
                        sh './mvnw clean org.sonarsource.scanner.maven:sonar-maven-plugin:3.9.0.2155:sonar'
                    }
                }
            }
        }
    }
}
