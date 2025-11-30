pipeline {
    agent any

    environment {
        REGISTRY = "gharbimahdi"
        IMAGE = "studentmang-app"

        SONAR_HOST_URL = "http://192.168.33.10:9000"
        APP_DAST_URL   = "http://192.168.49.2:32639"

        GITLEAKS_REPORT = "gitleaks-report.json"
    }

    stages {

        /* ------------------------ GITLEAKS ------------------------ */
        stage('Clone Repository & Secrets Scan (Gitleaks)') {
            steps {
                git branch: 'master', url: 'https://github.com/MahdiGharbi-prog/student-management-devops.git'

                sh '''
                    echo "🔒 Running Gitleaks..."
                    gitleaks detect -f json --report-path ${GITLEAKS_REPORT} --source .
                '''
            }
            post {
                always {
                    archiveArtifacts artifacts: "${GITLEAKS_REPORT}", allowEmptyArchive: true
                }
            }
        }

        /* ------------------------- MAVEN -------------------------- */
        stage('Build with Maven') {
            steps {
                sh 'mvn clean package -DskipTests'
            }
        }

        /* ------------------------- OWASP DC ------------------------ */
        stage('Dependency Check (SCA)') {
            steps {
                sh '''
                    echo "🔍 Running OWASP Dependency-Check..."
                    mvn org.owasp:dependency-check-maven:check \
                        -Dformat=HTML \
                        -DskipAssembly=true \
                        -DfailBuildOnCVSS=7
                '''
            }
            post {
                always {
                    archiveArtifacts artifacts: 'target/dependency-check-report.html', allowEmptyArchive: true
                }
            }
        }

        /* -------------------------- SONAR -------------------------- */
        stage('SonarQube (SAST)') {
            steps {
                withSonarQubeEnv('SonarQube') {
                    withCredentials([string(credentialsId: 'sonarqube-token', variable: 'SONAR_TOKEN')]) {
                        sh '''
                            echo "📊 Running SonarQube static analysis..."
                            mvn sonar:sonar \
                                -Dsonar.projectKey=studentmang-app \
                                -Dsonar.host.url=$SONAR_HOST_URL \
                                -Dsonar.token=$SONAR_TOKEN
                        '''
                    }
                }
            }
        }

        /* ------------------------- DOCKER -------------------------- */
        stage('Build Docker Image') {
            steps {
                script {
                    GIT_COMMIT = sh(script: "git rev-parse --short HEAD", returnStdout: true).trim()

                    sh """
                        echo "🐳 Building Docker image..."
                        docker build -t $REGISTRY/$IMAGE:latest -t $REGISTRY/$IMAGE:$GIT_COMMIT .
                    """
                }
            }
        }

        /* ------------------------- TRIVY --------------------------- */
        stage('Trivy Scan') {
            steps {
                sh '''
                    echo "🔎 Running Trivy image scan..."

                    trivy image \
                        --format json \
                        --scanners vuln,misconfig \
                        --ignore-unfixed \
                        --timeout 15m \
                        --output trivy-report.json \
                        gharbimahdi/studentmang-app:latest
                '''
            }
            post {
                always {
                    archiveArtifacts artifacts: 'trivy-report.json', allowEmptyArchive: true
                }
            }
        }

        /* -------------------------- NIKTO -------------------------- */
        stage('Nikto Scan (DAST)') {
            steps {
                sh '''
                    echo "💥 Running Nikto DAST scan..."
                    nikto -h $APP_DAST_URL \
                          -Format html \
                          -o nikto-report.html \
                          -maxtime 60 || true
                '''
            }
            post {
                always {
                    archiveArtifacts artifacts: 'nikto-report.html', allowEmptyArchive: true
                }
            }
        }

        /* ------------------------ DOCKER HUB ----------------------- */
        stage('Push to Docker Hub') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'dockerhub', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                    script {
                        sh """
                            echo "\$DOCKER_PASS" | docker login -u "\$DOCKER_USER" --password-stdin

                            docker push $REGISTRY/$IMAGE:latest
                            docker push $REGISTRY/$IMAGE:$GIT_COMMIT

                            docker logout
                        """
                    }
                }
            }
        }

        /* -------------------------- SUMMARY ------------------------ */
        stage('Generate Summary Report') {
            steps {
                script {
                    def now = sh(script: "date", returnStdout: true).trim()

                    writeFile file: 'summary-report.html', text: """
                    <html><head><title>DevSecOps Security Report</title></head>
                    <body>
                        <h2>📘 DevSecOps Pipeline Summary</h2>
                        <ul>
                            <li><a href='dependency-check-report.html'>OWASP Dependency Check</a></li>
                            <li><a href='trivy-report.json'>Trivy Image Scan</a></li>
                            <li><a href='nikto-report.html'>Nikto DAST Scan</a></li>
                            <li><a href='${GITLEAKS_REPORT}'>Gitleaks Secrets Scan</a></li>
                            <li><a href='${SONAR_HOST_URL}/dashboard?id=studentmang-app'>SonarQube Dashboard</a></li>
                        </ul>
                        <p>Generated on Jenkins – ${now}</p>
                    </body></html>
                    """
                }
                archiveArtifacts artifacts: 'summary-report.html', allowEmptyArchive: true
            }
        }
    }

    /* -------------------------- GLOBAL POST ---------------------- */
    post {
        always {
            echo '🎯 Pipeline finished.'
        }

        success {
            emailext(
                to: '3amarbouzwer1231@gmail.com',
                subject: "SUCCESS ✅ - ${env.JOB_NAME} #${env.BUILD_NUMBER}",
                mimeType: 'text/html',
                body: "<h3>🎉 Build Successful!</h3>"
            )
        }

        failure {
            emailext(
                to: '3amarbouzwer1231@gmail.com',
                subject: "FAILURE ❌ - ${env.JOB_NAME} #${env.BUILD_NUMBER}",
                mimeType: 'text/html',
                body: "<h3>❌ Build Failed</h3>"
            )
        }
    }
}
