node {
    
    try {
        stage('Checkout') {
            checkout scm

            sh 'git log HEAD^..HEAD --pretty="%h %an - %s" > GIT_CHANGES'
            def lastChanges = readFile('GIT_CHANGES')
            slackSend color: "warning", message: "Started `${env.JOB_NAME}#${env.BUILD_NUMBER}`\n\n_The changes:_\n${lastChanges}"
        }

        stage('Debug') {
            echo "DB_PASSWORD is ${env.DB_PASSWORD}" // Be cautious with this line in production
        }

        stage('Test') {
            withCredentials([string(credentialsId: 'DB_PASSWORD', variable: 'DB_PASSWORD')]) {
                    sh '''
                    virtualenv env -p python3.10
                    . env/bin/activate  # Use dot notation for activation
                    pip install -r requirements.txt
                    export DB_NAME=defaultdb
                    export DB_USER=doadmin
                    export DB_PASSWORD=${DB_PASSWORD}
                    export DB_HOST=db-postgresql-blr1-53371-do-user-14533663-0.j.db.ondigitalocean.com
                    export DB_PORT=25060
                    python3.10 manage.py test --testrunner=myproject.tests.test_runners.NoDbTestRunner
                    '''
            }
        }

        stage('Deploy') {
    steps {
        sh '''
        # Ensure virtual environment exists and activate it
        if [ ! -d "/opt/envs/cicdproject" ]; then
            python3.10 -m venv /opt/envs/cicdproject
        fi
        source /opt/envs/cicdproject/bin/activate
        
        # Install dependencies
        pip install -r requirements.txt

        # Fix permissions
        chmod +x ./manage.py

        # Run deployment script
        ./deployment/deploy_prod.sh
        '''
    }
}


        stage('Publish results') {
            slackSend color: "good", message: "Build successful: `${env.JOB_NAME}#${env.BUILD_NUMBER}` <${env.BUILD_URL}|Open in Jenkins>"
        }
    } catch (err) {
        slackSend color: "danger", message: "Build failed :face_with_head_bandage: \n`${env.JOB_NAME}#${env.BUILD_NUMBER}` <${env.BUILD_URL}|Open in Jenkins>"
        throw err
    }
}
