pipeline {
    agent any

    environment {
        // Nom du serveur SonarQube configuré dans Jenkins
        SONARQUBE = 'SonarQube'
    }

    stages {
        stage('Checkout') {
            steps {
                // Récupération du code depuis Git
                git url: 'https://github.com/ghaithelbenna/student-management-devops.git', branch: 'master'
            }
        }

        stage('Build') {
            steps {
                dir('student-man-main') {
                    sh 'chmod +x mvnw'
                    // Compilation et tests (skipTests si tu veux éviter les tests)
                    sh './mvnw clean verify'
                }
            }
        }

        stage('SonarQube Analysis') {
            steps {
                dir('student-man-main') {
                    // Injection des variables d'environnement SonarQube configurées dans Jenkins
                    withSonarQubeEnv(installationName: SONARQUBE) {
                        // Lancement de l'analyse SonarQube
                        sh """
                            ./mvnw sonar:sonar \
                                -Dsonar.projectKey=tn.esprit:student-management \
                                -Dsonar.java.binaries=target/classes \
                                -Dsonar.coverage.jacoco.xmlReportPaths=target/site/jacoco/jacoco.xml
                        """
                    }
                }
            }
        }

        stage('Quality Gate') {
            steps {
                // Attente de la fin de l'analyse et évaluation de la Quality Gate
                timeout(time: 5, unit: 'MINUTES') {
                    waitForQualityGate abortPipeline: true
                }
            }
        }
    }

    post {
        success {
            echo 'Pipeline terminé avec succès et Quality Gate OK ✅'
        }
        failure {
            echo 'Pipeline échoué ou Quality Gate KO ❌'
        }
    }
}
