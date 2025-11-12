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

        stage('Build') {
            steps {
                dir('student-man-main') {
                    // Compile le projet et génère les classes
                    sh './mvnw clean install -DskipTests'
                }
            }
        }

        stage('SonarQube Scan') {
            steps {
                dir('student-man-main') {
                    withSonarQubeEnv('SonarQube') {
                        // Analyse SonarQube en indiquant le chemin des classes compilées
                        sh './mvnw sonar:sonar -Dsonar.host.url=http://localhost:32000 -Dsonar.java.binaries=target/classes'
                    }
                }
            }
        }
    }
}
