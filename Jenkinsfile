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
                echo '========== BUILD STAGE =========='

                sh '''
                    set -e

                    composer install --no-interaction --prefer-dist

                    mkdir -p database
                    touch database/testing.sqlite

                    cp .env.example .env

                    php artisan key:generate

                    echo "Build completed successfully"
                '''
            }
        }

        stage('Test') {
            steps {
                echo '========== TEST STAGE =========='

                sh '''
                    set -e

                    php artisan config:clear

                    php artisan migrate:fresh --env=testing

                    php artisan test

                    echo "Tests passed successfully"
                '''
            }
        }

        stage('Package') {
            steps {
                echo '========== PACKAGE STAGE =========='

                sh '''
                    set -e

                    mkdir -p deployment

                    tar \
                        --exclude=.git \
                        --exclude=vendor \
                        --exclude=node_modules \
                        --exclude=.env \
                        --exclude=deployment \
                        -czf deployment/laravel-app.tar.gz .
                '''

                archiveArtifacts(
                    artifacts: 'deployment/laravel-app.tar.gz',
                    fingerprint: true
                )
            }
        }

        stage('Deploy') {
            steps {
                echo '========== DEPLOY STAGE =========='

                sh '''
                    set -e

                    DEPLOY_DIR=/var/lib/jenkins/laravel-live

                    mkdir -p "$DEPLOY_DIR"

                    rsync -a --delete \
                        --exclude='.git' \
                        --exclude='deployment' \
                        "$WORKSPACE/" "$DEPLOY_DIR/"

                    cd "$DEPLOY_DIR"

                    mkdir -p database
                    touch database/database.sqlite

                    # Create deployment environment if needed.
                    if [ ! -f .env ]; then
                        cp .env.example .env
                        php artisan key:generate
                    fi

                    # Configure SQLite for this lab deployment.
                    sed -i 's/^DB_CONNECTION=.*/DB_CONNECTION=sqlite/' .env

                    sed -i \
                        's|^DB_DATABASE=.*|DB_DATABASE=/var/lib/jenkins/laravel-live/database/database.sqlite|' \
                        .env

                    # Clear cached configuration and migrate deployment DB.
                    php artisan config:clear
                    php artisan migrate --force

                    # Start the local development server if it is not running.
                    if ! curl -fsS http://127.0.0.1:8000/up >/dev/null; then
                        BUILD_ID=dontKillMe nohup \
                            php artisan serve \
                            --host=0.0.0.0 \
                            --port=8000 \
                            > "$DEPLOY_DIR/server.log" 2>&1 &

                        sleep 3
                    fi

                    # Verify that Laravel is responding.
                    curl -fsS http://127.0.0.1:8000/up

                    echo "Deployment completed successfully"
                    echo "Open http://localhost:8000 in your Ubuntu browser"
                '''
            }
        }
    }

    post {
        success {
            echo 'CI/CD PIPELINE SUCCESSFUL: Build, Test, Package and Deploy completed.'
        }

        failure {
            echo 'CI/CD PIPELINE FAILED. Check Console Output for the failing stage.'
        }

        always {
            echo 'Pipeline execution finished.'
        }
    }
}
