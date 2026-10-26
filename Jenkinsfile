pipeline {
    agent any

    environment {
        APP_KEY = credentials('laravel-app-key')
        DB_PASSWORD = credentials('laravel-db-password')
        MYSQL_ROOT_PASSWORD = credentials('laravel-mysql-root-password')
    }

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
                sh 'docker compose up -d'
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

                    echo "Checking running containers..."
                    docker compose ps

                    echo "Checking Laravel..."
                    docker compose exec -T app \
                        php artisan --version

                    echo "Checking application HTTP response..."

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
            echo 'SUCCESS: Laravel CI/CD pipeline completed.'
            echo 'Application URL: http://localhost:8000'
        }

        failure {
            echo 'FAILED: Check the Jenkins Console Output.'
        }

        always {
            echo 'Pipeline execution finished.'
        }
    }
}

