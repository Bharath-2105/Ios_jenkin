pipeline {
    agent any
    
    environment {
        FASTLANE_HOME = "/opt/homebrew/bin/fastlane"
    }
    
    stages {
        stage('Checkout') {
            steps {
                git
            }
        }
        
        stage('Build') {
            steps {
                sh """
                    cd Instant-AR/
                    export PATH="$PATH:$FASTLANE_HOME"
                    fastlane build_app
                """
            }
        }
    }
    
    post {
        always {
            
        }
    }
}
