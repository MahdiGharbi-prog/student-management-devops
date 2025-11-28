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
                        gitleaks detect -f json --report-path $GITLEAKS_REPORT --source . || true
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
                            -DskipAssembly=true || true
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
                        sh '''
                            echo "📊 Running SonarQube static code analysis..."
                            mvn sonar:sonar \
                                -Dsonar.projectKey=studentmang-app \
                                -Dsonar.host.url=${SONAR_HOST_URL} \
                                -Dsonar.login=$SONARQUBE || true
                        '''
                    }
                }
            }
        }

        /* ------------------------- DOCKER -------------------------- */
        stage('Build Docker Image') {
    steps {
        dir('student-man-main') {
            script {
                // Get the current Git commit hash
                GIT_COMMIT = sh(script: "git rev-parse --short HEAD", returnStdout: true).trim()
                
                // Build Docker image with both 'latest' and commit tag
                sh """
                    echo "🐳 Building Docker image..."
                    docker build -t $REGISTRY/$IMAGE:latest -t $REGISTRY/$IMAGE:$GIT_COMMIT .
                    
                    echo "✅ Image built successfully:"
                    docker images | grep $IMAGE
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
trivy image --cache-dir $WORKSPACE/trivy-cache \
            --security-checks vuln \
            --severity HIGH,CRITICAL \
            --light \
            --ignore-unfixed \
            --no-progress \
            --timeout 90s \
            --format table \
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
                        echo "💥 Running Nikto web vulnerability scan on $APP_DAST_URL..."
                        nikto -h $APP_DAST_URL \
                              -maxtime 60 \
                              -Format html \
                              -o nikto-report.html || true
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
                        echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin

                        echo "🚀 Pushing image with 'latest' tag..."
                        docker push $REGISTRY/$IMAGE:latest

                        echo "🚀 Pushing image with commit tag..."
                        docker push $REGISTRY/$IMAGE:$GIT_COMMIT

                        echo "🔒 Logging out from Docker Hub..."
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
                            <li><a href='target/dependency-check-report.html'>OWASP Dependency Check (SCA)</a></li>
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

    post {
        always {
            echo '🎯 Pipeline finished. Reports generated successfully.'
        }
        failure {
            echo '❌   Pipeline failed. Check logs and reports.'
        }
    }
}
