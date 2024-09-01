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
            // Use bash explicitly for commands that need it
            sh '''
            virtualenv env -p python3.10
            . env/bin/activate  # Use dot notation for activation
            pip install -r requirements.txt
            export DB_PASSWORD=${DB_PASSWORD}
            python3.10 manage.py test --testrunner=myproject.tests.test_runners.NoDbTestRunner
            '''
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
