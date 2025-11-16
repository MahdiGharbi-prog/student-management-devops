pipeline {
    agent any
    environment {
        DOCKER_CREDENTIALS = credentials('jenkins_docker')
        DOCKER_IMAGE = "ghaith6789/student-management:${env.BUILD_NUMBER}"
        SONAR_TOKEN = credentials('sonarqube_token')
       
        // Noms dynamiques pour éviter les conflits
        ZAP_NETWORK = "zap-net-${env.BUILD_NUMBER}"
        APP_CONTAINER = "app-test-${env.BUILD_NUMBER}"
    }
    stages {
        stage('Checkout') {
            steps {
                checkout scmGit(
                    branches: [[name: '*/main']],  // ← CORRIGÉ : main, pas master
                    userRemoteConfigs: [[url: 'https://github.com/ghaithelbenna/student-management-devops.git']]
                )
            }
        }

        stage('Compile & Test') {
            steps {
                dir('student-man-main') {
                    sh 'chmod +x mvnw'
                    sh './mvnw clean test'
                }
                junit testResults: 'target/surefire-reports/*.xml', allowEmptyResults: true
            }
        }

        stage('Build JAR') {
            steps {
                dir('student-man-main') {
                    sh './mvnw clean package -DskipTests'
                }
                archiveArtifacts artifacts: 'target/*.jar', allowEmptyArchive: true
            }
        }

        stage('SAST - SonarQube') {
            steps {
                dir('student-man-main') {
                    catchError(buildResult: 'UNSTABLE', stageResult: 'FAILURE') {
                        withSonarQubeEnv('SonarQube') {
                            sh './mvnw sonar:sonar -Dsonar.projectKey=devops_git -Dsonar.host.url=http://192.168.33.10:32000 -Dsonar.token=$SONAR_TOKEN || true'
                        }
                    }
                }
            }
        }

        stage('SCA - OWASP') {
            steps {
                dir('student-man-main') {
                    sh './mvnw org.owasp:dependency-check-maven:check -Dformat=ALL || true'
                    archiveArtifacts artifacts: 'target/dependency-check-report.*', allowEmptyArchive: true
                }
            }
        }

        stage('Secrets Scan') {
            steps {
                dir('student-man-main') {
                    sh 'gitleaks detect --source . --redact --report-format json --report-path gitleaks-report.json || true'
                    archiveArtifacts artifacts: 'gitleaks-report.json', allowEmptyArchive: true
                }
            }
        }

        stage('Docker Build') {
            steps {
                dir('student-man-main') {
                    withCredentials([usernamePassword(
                        credentialsId: 'jenkins_docker',
                        usernameVariable: 'DOCKER_USER',
                        passwordVariable: 'DOCKER_PASS'
                    )]) {
                        sh '''
                            echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin
                            docker build -t ${DOCKER_IMAGE} .
                        '''
                    }
                }
            }
        }

        stage('Docker Scan - Trivy') {
            steps {
                dir('student-man-main') {
                    catchError(buildResult: 'UNSTABLE', stageResult: 'FAILURE') {
                        sh """
                            trivy image --scanners vuln ${DOCKER_IMAGE} \
                              --format template \
                              --template "@templates/custom-trivy.tpl" \
                              --output trivy-docker.html || echo "<h1>Scan échoué</h1>" > trivy-docker.html
                            trivy image --scanners vuln ${DOCKER_IMAGE} \
                              --format json \
                              --output trivy-docker.json || echo '{"results": []}' > trivy-docker.json
                        """
                    }
                    archiveArtifacts artifacts: 'trivy-docker.*', allowEmptyArchive: true
                }
            }
        }

        stage('DAST - OWASP ZAP') {
            steps {
                dir('student-man-main') {
                    sh '''
                        APP=${APP_CONTAINER}
                        NET=${ZAP_NETWORK}

                        # Nettoyage
                        docker rm -f $APP || true
                        docker network rm $NET || true

                        # Création réseau + lancement app
                        docker network create $NET
                        docker run -d --network $NET --name $APP ${DOCKER_IMAGE}

                        # Attente intelligente (max 2 min)
                        timeout 120 bash -c "until curl -f http://$APP:8080 >/dev/null 2>&1; do sleep 5; done" || echo "App non prête, scan quand même"

                        # Scan ZAP (image locale, rapports générés dedans)
                        docker run --network $NET \
                          -v "$(pwd):/zap/wrk" \
                          -t zaproxy/zap-stable \
                          zap-baseline.py \
                            -t http://$APP:8080 \
                            -x /zap/wrk/zap-report.xml \
                            -r /zap/wrk/zap-report.html || true

                        # Récupération rapports
                        docker cp $APP:/zap/wrk/zap-report.xml . || true
                        docker cp $APP:/zap/wrk/zap-report.html . || true

                        # Nettoyage
                        docker rm -f $APP || true
                        docker network rm $NET || true
                    '''
                    archiveArtifacts artifacts: 'zap-report.*', allowEmptyArchive: true
                }
            }
        }

        stage('Push Docker Hub') {
            when {
                expression { currentBuild.currentResult == 'SUCCESS' }
            }
            steps {
                dir('student-man-main') {
                    withCredentials([usernamePassword(
                        credentialsId: 'jenkins_docker',
                        usernameVariable: 'DOCKER_USER',
                        passwordVariable: 'DOCKER_PASS'
                    )]) {
                        sh 'echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin'
                        sh "docker push ${DOCKER_IMAGE}"
                    }
                }
            }
        }
    }

    // NETTOYAGE GARANTI + PRÉVENTION DISQUE PLEIN
    post {
        always {
            sh '''
                echo "Nettoyage Docker automatique..."
                docker rm -f ${APP_CONTAINER} || true
                docker network rm ${ZAP_NETWORK} || true
                docker system prune -af --volumes || true  # ← LIBÈRE L'ESPACE
            '''
            archiveArtifacts artifacts: 'student-man-main/target/*.jar,student-man-main/target/dependency-check-report.*,student-man-main/trivy-docker.*,student-man-main/gitleaks-report.json,student-man-main/zap-report.*', allowEmptyArchive: true
        }
    }
}
