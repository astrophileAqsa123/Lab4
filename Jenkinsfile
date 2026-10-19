pipeline {
    agent any

    stages {
        stage('Build') {
            steps {
                echo 'Building Laravel Docker image'
                sh '''
                    set -e
                    docker build -t laravel-lab4:${BUILD_NUMBER} .
                '''
            }
        }

        stage('Test') {
            steps {
                echo 'Running Laravel tests'
                sh '''
                    set -e
                    docker run --rm \
                      -e APP_ENV=testing \
                      -e APP_KEY=base64:AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA= \
                      -e DB_CONNECTION=sqlite \
                      -e DB_DATABASE=/tmp/testing.sqlite \
                      -e SESSION_DRIVER=file \
                      -e CACHE_STORE=file \
                      laravel-lab4:${BUILD_NUMBER} \
                      sh -c 'touch /tmp/testing.sqlite &&
                             php artisan config:clear &&
                             php artisan migrate:fresh &&
                             php artisan test'
                '''
            }
        }

        stage('Deploy') {
            steps {
                echo 'Deploying Laravel container'
                sh '''
                    set -e

                    docker rm -f laravel-live || true

                    docker run -d \
                      --name laravel-live \
                      --restart unless-stopped \
                      -p 8000:8000 \
                      -e APP_ENV=production \
                      -e APP_KEY="$APP_KEY" \
                      -e DB_CONNECTION=sqlite \
                      -e DB_DATABASE=/var/www/database/database.sqlite \
                      -e SESSION_DRIVER=file \
                      -e CACHE_STORE=file \
                      -v /var/lib/jenkins/laravel-data:/var/www/database \
                      laravel-lab4:${BUILD_NUMBER}

                    sleep 5
                    docker logs --tail 50 laravel-live
                    curl --retry 5 --retry-connrefused --retry-delay 2 \
                      -fsS http://127.0.0.1:8000/up
                '''
            }
        }
    }

    post {
        success {
            echo 'Build, Test and Deploy successful!'
        }
        failure {
            echo 'Pipeline failed. Check Console Output.'
        }
    }
}
