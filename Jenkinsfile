pipeline {
    agent any

    options {
        timestamps()
        disableConcurrentBuilds()
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Build Docker Image') {
            steps {
                sh 'docker compose build app'
            }
        }

        stage('Deploy Application') {
            steps {
                sh '''
                    docker compose up -d
                '''
            }
        }

        stage('Database Migration') {
            steps {
                sh '''
                    docker compose exec -T app \
                        php artisan migrate --force
                '''
            }
        }

        stage('Verify Deployment') {
            steps {
                sh '''
                    set -e
                    docker compose ps
                    docker compose exec -T app \
                        php artisan --version

                    for i in $(seq 1 20); do
                        if curl -fsS http://localhost:8000/ \
                            -o /dev/null; then
                            echo "SUCCESS: Laravel is accessible."
                            exit 0
                        fi
                        sleep 3
                    done

                    echo "ERROR: Application health check failed."
                    docker compose logs --tail=100 app
                    exit 1
                '''
            }
        }
    }

    post {
        success {
            echo 'CI/CD pipeline completed successfully.'
        }
        failure {
            echo 'Pipeline failed. Check the Jenkins console output.'
        }
    }
}
