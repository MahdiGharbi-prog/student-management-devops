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
                    sh 'chmod +x mvnw'
                }
            }
        }

        stage('Build') {
            steps {
                dir('student-man-main') {
                    sh './mvnw clean install -DskipTests'
                }
            }
        }

        stage('SonarQube Scan') {
            steps {
                dir('student-man-main') {
                    withSonarQubeEnv('SonarQube') {
                        sh './mvnw sonar:sonar -Dsonar.host.url=http:192.168.33.10:32000 -Dsonar.java.binaries=target/classes'
                    }
                }
            }
        }

        stage('Quality Gate') {
            steps {
                timeout(time: 1, unit: 'MINUTES') {
                    waitForQualityGate abortPipeline: true
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
