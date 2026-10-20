pipeline {
    agent any

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Build Docker Image') {
            steps {
                sh 'docker build -t lab4-app:${BUILD_NUMBER} .'
            }
        }

        stage('Test Laravel App') {
            steps {
                script {
                    env.APP_KEY = sh(
                        script: "php -r 'echo \"base64:\" . base64_encode(random_bytes(32));'",
                        returnStdout: true
                    ).trim()
                }
                sh '''
                    docker run --rm \
                      -e APP_KEY="$APP_KEY" \
                      -e APP_ENV=testing \
                      -e DB_CONNECTION=sqlite \
                      -e DB_DATABASE=/tmp/testing.sqlite \
                      -e CACHE_STORE=file \
                      -e SESSION_DRIVER=file \
                      -e QUEUE_CONNECTION=sync \
                      lab4-app:${BUILD_NUMBER} \
                      sh -c 'touch /tmp/testing.sqlite && php artisan test'
                '''
            }
        }

        stage('Deploy Container') {
            steps {
                sh '''
                    docker rm -f lab4-app 2>/dev/null || true
                    docker volume create lab4-db
                    docker run -d \
                      --name lab4-app \
                      --restart unless-stopped \
                      -p 8081:8000 \
                      -e APP_KEY="$APP_KEY" \
                      -e APP_ENV=production \
                      -e APP_DEBUG=false \
                      -e APP_URL=http://localhost:8081 \
                      -e DB_CONNECTION=sqlite \
                      -e DB_DATABASE=/var/www/database/database.sqlite \
                      -e CACHE_STORE=file \
                      -e SESSION_DRIVER=file \
                      -e QUEUE_CONNECTION=sync \
                      -v lab4-db:/var/www/database \
                      lab4-app:${BUILD_NUMBER}
                '''
            }
        }
    }
}
