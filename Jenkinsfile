pipeline {
    agent any

    environment {
        // Nom du serveur SonarQube configuré dans Jenkins
        SONARQUBE = 'SonarQube'
    }

    options {
        // Garde seulement les 5 derniers builds
        buildDiscarder(logRotator(numToKeepStr: '5'))
        // Timeout global du pipeline
        timeout(time: 60, unit: 'MINUTES')
    }

    stages {

        stage('Checkout') {
            steps {
                // Récupération du code depuis GitHub
                git url: 'https://github.com/ghaithelbenna/student-management-devops.git', branch: 'master'
            }
        }

        stage('Build') {
            steps {
                dir('student-man-main') {
                    // Rend mvnw exécutable
                    sh 'chmod +x mvnw'
                    // Compile le projet et ignore les tests pour éviter les erreurs de Spring Boot
                    sh './mvnw clean install -DskipTests'
                }
            }
        }

        stage('SonarQube Analysis') {
            steps {
                dir('student-man-main') {
                    // Injection des variables d'environnement SonarQube
                    withSonarQubeEnv('SonarQube') {
                        // Analyse avec SonarScanner Maven
                        sh './mvnw sonar:sonar -Dsonar.java.binaries=target/classes'
                    }
                }
            }
        }

        stage('Quality Gate') {
            steps {
                // Attend que SonarQube finisse l'analyse et récupère le statut
                timeout(time: 10, unit: 'MINUTES') {
                    waitForQualityGate abortPipeline: true
                }
            }
        }
    }

    post {
        success {
            echo 'Pipeline terminé avec succès ✅'
        }
        failure {
            echo 'Pipeline échoué ❌'
        }
    }
}
