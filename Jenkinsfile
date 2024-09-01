node {
    // Securely retrieve the database password from Jenkins credentials
    environment {
        DB_PASSWORD = credentials('DB_PASSWORD') // Ensure this ID matches your Jenkins credentials ID
    }

    try {
        stage('Checkout') {
            checkout scm

            sh 'git log HEAD^..HEAD --pretty="%h %an - %s" > GIT_CHANGES'
            def lastChanges = readFile('GIT_CHANGES')
            slackSend color: "warning", message: "Started `${env.JOB_NAME}#${env.BUILD_NUMBER}`\n\n_The changes:_\n${lastChanges}"
        }

        stage('Test') {
            sh 'virtualenv env -p python3.10'
            sh '. env/bin/activate'
            sh 'env/bin/pip install -r requirements.txt'

            // Debug: Print environment variables for verification
            sh 'echo DB_PASSWORD=${env.DB_PASSWORD}'

            // Set environment variable for Django test
            sh """
            export DB_PASSWORD=${env.DB_PASSWORD}
            env/bin/python3.10 manage.py test --testrunner=myproject.tests.test_runners.NoDbTestRunner
            """
        }

        stage('Deploy') {
            sh 'chmod +x ./deployment/deploy_prod.sh'
            sh './deployment/deploy_prod.sh'
        }

        stage('Publish results') {
            slackSend color: "good", message: "Build successful: `${env.JOB_NAME}#${env.BUILD_NUMBER}` <${env.BUILD_URL}|Open in Jenkins>"
        }
    } catch (err) {
        slackSend color: "danger", message: "Build failed :face_with_head_bandage: \n`${env.JOB_NAME}#${env.BUILD_NUMBER}` <${env.BUILD_URL}|Open in Jenkins>"
        throw err
    }
}
