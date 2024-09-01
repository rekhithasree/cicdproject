#!groovy

node {
    environment {
        DB_NAME = 'defaultdb'
        DB_USER = 'doadmin'
        DB_PASSWORD = credentials('DB_PASSWORD') // Ensure this ID matches your Jenkins credentials ID
        DB_HOST = 'db-postgresql-blr1-53371-do-user-14533663-0.j.db.ondigitalocean.com'
        DB_PORT = '25060'
    }

    try {
        stage('Checkout') {
            checkout scm

            sh 'git log HEAD^..HEAD --pretty="%h %an - %s" > GIT_CHANGES'
            def lastChanges = readFile('GIT_CHANGES')
            slackSend color: "warning", message: "Started `${env.JOB_NAME}#${env.BUILD_NUMBER}`\n\n_The changes:_\n${lastChanges}"
        }

        stage('Test') {
            sh '''
            virtualenv env -p python3.10
            . env/bin/activate
            pip install -r requirements.txt
            export DB_NAME=${DB_NAME}
            export DB_USER=${DB_USER}
            export DB_PASSWORD=${DB_PASSWORD}
            export DB_HOST=${DB_HOST}
            export DB_PORT=${DB_PORT}
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
