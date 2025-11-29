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

        dir('student-man-main') {
            sh '''
                echo "🔒 Running Gitleaks Secrets Scan..."
                gitleaks detect -f json --report-path $GITLEAKS_REPORT --source .
            '''
        }
    }
    post {
        always {
            archiveArtifacts artifacts: "student-man-main/${GITLEAKS_REPORT}", allowEmptyArchive: true
        }
    }
}

        /* ------------------------- MAVEN -------------------------- */
        stage('Build with Maven') {
            steps {
                dir('student-man-main') {
                    sh 'mvn clean package -DskipTests'
                }
            }
        }

        /* ------------------------- OWASP DC ------------------------ */
        stage('Dependency Check (SCA)') {
    steps {
        dir('student-man-main') {
            sh '''
                echo "🔍 Running OWASP Dependency-Check..."
                mvn org.owasp:dependency-check-maven:check \
                    -Dformat=HTML \
                    -DskipAssembly=true \
                    -DfailBuildOnCVSS=7
            '''
        }
    }
    post {
        always {
            archiveArtifacts artifacts: 'student-man-main/target/dependency-check-report.html', allowEmptyArchive: true
        }
    }
}


        /* -------------------------- SONAR -------------------------- */
        stage('SonarQube (SAST)') {
            environment {
                SONARQUBE = credentials('sonarqube-token')
            }
            steps {
                dir('student-man-main') {
                    withSonarQubeEnv('SonarQube') {
                        sh """
                            echo "📊 Running SonarQube static code analysis..."
                            mvn sonar:sonar \
                                -Dsonar.projectKey=studentmang-app \
                                -Dsonar.host.url=$SONAR_HOST_URL \
                                -Dsonar.login=$SONARQUBE || true
                        """
                    }
                }
            }
        }

        /* ------------------------- DOCKER -------------------------- */
        stage('Build Docker Image') {
            steps {
                dir('student-man-main') {
                    script {
                        GIT_COMMIT = sh(script: "git rev-parse --short HEAD", returnStdout: true).trim()

                        sh """
                            echo "🐳 Building Docker image..."
                            docker build -t $REGISTRY/$IMAGE:latest -t $REGISTRY/$IMAGE:$GIT_COMMIT .
                        """
                    }
                }
            }
        }

        /* ------------------------- TRIVY --------------------------- */
        stage('Trivy Scan (Container Security)') {
            steps {
                dir('student-man-main') {
                    sh '''
                        mkdir -p $WORKSPACE/trivy-cache
                        trivy image \
                            --cache-dir $WORKSPACE/trivy-cache \
                            --security-checks vuln \
                            --severity HIGH,CRITICAL \
                            --light \
                            --ignore-unfixed \
                            --no-progress \
                            --timeout 90s \
                            --format html \
                            --output trivy-report.html \
                            $REGISTRY/$IMAGE:latest || true
                    '''
                }
            }
            post {
                always {
                    archiveArtifacts artifacts: 'student-man-main/trivy-report.html', allowEmptyArchive: true
                }
            }
        }

        /* -------------------------- NIKTO -------------------------- */
        stage('Nikto Scan (DAST)') {
            steps {
                dir('student-man-main') {
                    sh '''
                        echo "💥 Running Nikto DAST scan..."
                        nikto -h $APP_DAST_URL \
                              -Format html \
                              -o nikto-report.html \
                              -maxtime 60 || true
                    '''
                }
            }
            post {
                always {
                    archiveArtifacts artifacts: 'student-man-main/nikto-report.html', allowEmptyArchive: true
                }
            }
        }

        /* ------------------------ DOCKER HUB ----------------------- */
        stage('Push to Docker Hub') {
            steps {
                dir('student-man-main') {
                    withCredentials([usernamePassword(credentialsId: 'dockerhub', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                        script {
                            sh """
                                echo "📦 Logging in to Docker Hub..."
                                echo "\$DOCKER_PASS" | docker login -u "\$DOCKER_USER" --password-stdin

                                echo "🚀 Pushing image with 'latest' tag..."
                                docker push $REGISTRY/$IMAGE:latest

                                echo "🚀 Pushing image with commit tag..."
                                docker push $REGISTRY/$IMAGE:$GIT_COMMIT

                                echo "🔒 Logging out..."
                                docker logout
                            """
                        }
                    }
                }
            }
        }

        /* -------------------------- SUMMARY ------------------------ */
        stage('Generate Summary Report') {
            steps {
                script {
                    def now = sh(script: "date", returnStdout: true).trim()

                    writeFile file: 'student-man-main/summary-report.html', text: """
                    <html><head><title>DevSecOps Security Report</title></head>
                    <body>
                        <h2>📘 DevSecOps Pipeline Summary</h2>
                        <ul>
                            <li><a href='target/dependency-check-report.html'>OWASP Dependency Check</a></li>
                            <li><a href='trivy-report.html'>Trivy Image Scan</a></li>
                            <li><a href='nikto-report.html'>Nikto DAST Scan</a></li>
                            <li><a href='${GITLEAKS_REPORT}'>Gitleaks Secrets Scan</a></li>
                            <li><a href='${SONAR_HOST_URL}/dashboard?id=studentmang-app'>SonarQube Dashboard</a></li>
                        </ul>
                        <p>Generated on Jenkins – ${now}</p>
                    </body></html>
                    """
                }

                archiveArtifacts artifacts: 'student-man-main/summary-report.html', allowEmptyArchive: true
            }
        }
    }

    /* -------------------------- GLOBAL POST ---------------------- */
    post {

        always {
            echo '🎯 Pipeline finished. Reports generated successfully.'
        }

        success {
            emailext(
                to: '3amarbouzwer1231@gmail.com',
                subject: "SUCCESS ✅ - ${env.JOB_NAME} #${env.BUILD_NUMBER}",
                mimeType: 'text/html',
                body: """
                <h3>🎉 Build Successful!</h3>
                <p>Your Jenkins pipeline completed successfully.</p>
                <ul>
                    <li><b>Project:</b> ${env.JOB_NAME}</li>
                    <li><b>Build:</b> #${env.BUILD_NUMBER}</li>
                    <li><b>Status:</b> SUCCESS</li>
                    <li><b>Build URL:</b> <a href="${env.BUILD_URL}">${env.BUILD_URL}</a></li>
                </ul>
                """
            )
        }

        failure {
            emailext(
                to: '3amarbouzwer1231@gmail.com',
                subject: "FAILURE ❌ - ${env.JOB_NAME} #${env.BUILD_NUMBER}",
                mimeType: 'text/html',
                body: """
                <h3>❌ Build Failed</h3>
                <p>Your Jenkins pipeline failed.</p>
                <ul>
                    <li><b>Project:</b> ${env.JOB_NAME}</li>
                    <li><b>Build:</b> #${env.BUILD_NUMBER}</li>
                    <li><b>Status:</b> FAILED</li>
                    <li><b>Build URL:</b> <a href="${env.BUILD_URL}">${env.BUILD_URL}</a></li>
                </ul>
                <p>Please check logs and reports.</p>
                """
            )
        }
    }
}
