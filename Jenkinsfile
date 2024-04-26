pipeline {
    agent any{
        label 'mac_node4'
    }
    
    environment {
        FASTLANE_HOME = "/opt/homebrew/bin/fastlane"
    }
    
    stages {
        stage('Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/Bharath-2105/Ios_jenkin.git'
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
