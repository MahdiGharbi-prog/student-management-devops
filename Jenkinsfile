pipeline {
    agent any

    options {
        buildDiscarder(logRotator(numToKeepStr: '5'))
        timestamps()
    }

    stages {
        stage('Prepare') {
            steps {
                dir('student-man-main') {
                    // S'assurer que mvnw est exécutable
                    sh 'chmod +x mvnw'
                }
            }
        }

        stage('Build') {
            steps {
                dir('student-man-main') {
                    // Compiler le projet et générer les classes compilées
                    sh './mvnw clean install -DskipTests'
                }
            }
        }

        stage('SonarQube Scan') {
            steps {
                dir('student-man-main') {
                    // Exécuter le scan SonarQube
                    withSonarQubeEnv('SonarQube') {
                        sh './mvnw sonar:sonar -Dsonar.host.url=http://localhost:32000 -Dsonar.java.binaries=target/classes'
                    }
                }
            }
        }
    }

    post {
        success {
            echo 'Pipeline terminé avec succès !'
        }
        failure {
            echo 'Pipeline échoué. Vérifie les logs pour plus de détails.'
        }
    }
}
