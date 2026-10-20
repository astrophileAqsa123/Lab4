pipeline {
    agent any

    stages {
        stage('Build') {
            steps {
                echo 'Building Docker image...'
                sh 'docker build -t laravel-app:latest .'
            }
        }

        stage('Test') {
            steps {
                echo 'Running Laravel tests...'
                sh 'docker run --rm laravel-app:latest php artisan test'
            }
        }

        stage('Deploy') {
            steps {
                echo 'Deploying...'
                sh 'docker stop laravel-container || true'
                sh 'docker rm laravel-container || true'
                sh 'docker run -d --name laravel-container -p 8000:8000 laravel-app:latest'
            }
        }
    }
}
