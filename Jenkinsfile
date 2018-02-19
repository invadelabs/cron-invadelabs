pipeline {
    agent {
        docker {
            image 'ubuntu:artful'
            args '-u root'
            //args '-v $HOME/.m2:/root/.m2'
        }
    }
    stages {
        stage('Clone') {
            steps {
                sh "echo 'clone stage..'"
                checkout scm
                // git 'git@github.com:invadelabs/cron-invadelabs.git'
                // git 'https://github.com/invadelabs/cron-invadelabs.git'
            }
        }
        stage('Lint') {
            steps {
                sh "echo 'lint stage..'"
                sh "apt-get -qq update"
                sh "apt-get install -y shellcheck kcov"
                sh "shellcheck -x *.sh"
            }
        }
        stage('Test') {
            steps {
                // sh "for i in `ls *.sh`; do kcov coverage-$i $i; done;"
                // sh "bash <(curl -s https://codecov.io/bash)"
                sh "echo 'test stage..'"
            }
        }
    }
}
