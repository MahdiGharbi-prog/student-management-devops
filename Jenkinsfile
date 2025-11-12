pipeline {
    agent any

    options {
        buildDiscarder(logRotator(numToKeepStr: '5'))
    }

    stages {
        stage('Prepare') {
            steps {
                dir('student-man-main') {
                    sh 'chmod +x mvnw'
                }
            }
        }

        stage('Scan') {
            steps {
                dir('student-man-main') {
                    withSonarQubeEnv(installationName: 'SonarQube') {
                        sh './mvnw clean org.sonarsource.scanner.maven:sonar-maven-plugin:3.9.0.2155:sonar -Dsonar.host.url=http://localhost:32000'
                    }
                }
            }
        }
    }
}
