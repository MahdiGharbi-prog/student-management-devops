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
                        // URL correcte et token configuré dans Jenkins
                        sh './mvnw sonar:sonar -Dsonar.host.url=http://192.168.33.10:32000 -Dsonar.java.binaries=target/classes'
                    }
                }
            }
        }

        stage('Quality Gate') {
            steps {
                // Timeout suffisant pour que SonarQube finisse son traitement
                timeout(time: 1, unit: 'Hours') {
                    script {
                        // Attend la fin de l'analyse et récupère le status du Quality Gate
                        def qg = waitForQualityGate()
                        if (qg.status != 'OK') {
                            error "Pipeline échoué à cause du Quality Gate: ${qg.status}"
                        } else {
                            echo "Quality Gate OK ✅"
                        }
                    }
                }
            }
        }
    }

    post {
        success {
            echo 'Pipeline terminé avec succès ! 🎉'
        }
        failure {
            echo 'Pipeline échoué. Vérifie les logs pour plus de détails. ❌'
        }
    }
}
