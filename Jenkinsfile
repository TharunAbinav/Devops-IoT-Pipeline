pipeline {
    agent any

    environment {
        DEFAULT_ENDPOINT = 'a2ysgq4nuhlp7t-ats.iot.us-east-1.amazonaws.com'
        PROJECT_NAME     = 'iot-fullstack-project'
    }

    stages {
        stage('1. Checkout & Workspace Verification') {
            steps {
                echo "Checking project structure..."
                sh 'ls -la'
            }
        }

        stage('2. Static Code Analysis & Python Syntax Validation') {
            steps {
                echo "Validating Python syntax for IoT Publisher and Flask Dashboard..."
                sh 'python3 -m py_compile device.py frontend/app.py'
            }
        }

        stage('3. Automated Unit & Payload Tests') {
            steps {
                echo "Running automated unit tests on telemetry payload structure and Flask routes..."
                sh 'python3 -m unittest discover -s tests -p "test_*.py" -v'
            }
        }

        stage('4. Terraform Infrastructure Validation (IaC)') {
            steps {
                echo "Validating Terraform configuration files..."
                dir('terraform') {
                    sh 'terraform init -backend=false && terraform validate && terraform fmt -check'
                }
            }
        }

        stage('5. Build Docker Images') {
            steps {
                echo "Building IoT Sensor Publisher & Web Dashboard Docker images..."
                sh 'docker compose build iot-publisher iot-dashboard'
            }
        }

        stage('6. Deploy Full-Stack Containers') {
            steps {
                echo "Deploying IoT Sensor Publisher and Real-Time Web Dashboard via Docker Compose..."
                sh 'docker compose up -d iot-publisher iot-dashboard'
                sh 'docker compose ps'
            }
        }
    }

    post {
        success {
            echo "CI/CD Pipeline succeeded! Dashboard is live on http://localhost:5000"
        }
        failure {
            echo "CI/CD Pipeline failed. Inspect stage logs above for details."
        }
    }
}
