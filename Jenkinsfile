pipeline {
    agent any

    environment {
        APP_ENV = 'testing'
        DB_CONNECTION = 'sqlite'
        DB_DATABASE = 'database/testing.sqlite'
    }

    stages {
        stage('Build') {
            steps {
                echo 'Building Laravel application'
                sh '''
                    composer install --no-interaction --prefer-dist
                    mkdir -p database
                    touch database/testing.sqlite
                    cp .env.example .env
                    php artisan key:generate
                '''
            }
        }

        stage('Test') {
            steps {
                echo 'Running Laravel tests'
                sh '''
                    php artisan config:clear
                    php artisan migrate:fresh --env=testing
                    php artisan test
                '''
            }
        }

        stage('Deploy') {
            steps {
                echo 'Preparing deployment package'
                sh '''
                    mkdir -p "$WORKSPACE/deployment"
                    tar --exclude=.git \
                        --exclude=vendor \
                        --exclude=node_modules \
                        --exclude=.env \
                        -czf "$WORKSPACE/deployment/laravel-app.tar.gz" .
                    echo "Deployment package created successfully"
                '''
                archiveArtifacts artifacts: 'deployment/laravel-app.tar.gz',
                                 fingerprint: true
            }
        }
    }

    post {
        success {
            echo 'Build, Test and Deploy stages completed!'
        }
        failure {
            echo 'Pipeline failed. Check the stage logs.'
        }
    }
}
