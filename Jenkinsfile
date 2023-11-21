pipeline {
    agent any

    tools {
        // Install the Terraform version configured as "terraform" and add it to the path.
        terraform "terraform"
    }

    stages {
        stage('Build') {
            steps {
                // Get some code from a GitHub repository
                git branch: 'main', url: 'https://github.com/Haydenpal/Finalyear_project.git'
            }
        }

        stage("terraform -version") {
            steps {
                sh "terraform --version"
            }
        }

        stage("run-terraform") {
            steps {
                sh 'terraform init'
                sh 'terraform apply -auto-approve'
                sh 'terraform destroy -auto-approve'
            }
        }
    }
}
