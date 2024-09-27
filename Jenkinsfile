pipeline {
    agent any

    stages {

        // Add more stages as needed
        stage('Build and cleanu') {
            steps {
                echo 'Building...'
                sh 'docker compose down'
                sh 'docker compose up --build -d'
                sh 'docker system prune -a -f'
            }
        }


    }
}
