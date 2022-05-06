#!/usr/bin/env groovy
pipeline {
    agent any
    stages {
        stage('cleanup'){
            steps{
                deleteDir()
                dir("${workspace}@tmp"){
                    deleteDir()
                }
            }
        }
        stage('debug'){
            steps{
                sh 'printenv'
            }
        }
        stage('SCM: checkout'){
            steps{
                checkout scm
                git url: 'https://github.com/andreaswendlandt/gotham.git'
                sh "git pull origin 20220506_add_jenkinsfile"
            }
        }
        stage('Shellcheck the project unix_file_permission_converter') {
            steps {
                sh "shellcheck unix_file_permission_converter/*.sh"
            }
        }
    }
}
