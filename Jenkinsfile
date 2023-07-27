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
                sh "git pull origin master"
            }
        }
        stage('Shellcheck unix_file_permission_converter') {
            steps {
                sh "shellcheck unix_file_permission_converter/*.sh"
            }
        }
        stage('Shellcheck my_lib') {
            steps {
                sh "shellcheck my_lib/my_lib"
            }
        }
        stage('Shellcheck password_generator') {
            steps {
                sh "shellcheck password_generator/password_generator.sh"
            }
        }
        stage('Shellcheck vulnerability_scanner') {
            steps {
                sh "shellcheck vulnerability_scanner/vulnerability.sh"
            }
        }
        stage('Shellcheck file encryption/decryption scripts') {
            steps {
                sh "shellcheck file_encryption-decryption/encrypt.sh"
                sh "shellcheck file_encryption-decryption/decrypt.sh"
                sh "shellcheck file_encryption-decryption/file_encryption.sh"
            }
        }
        stage('Shellcheck password_quality') {
            steps {
                sh "shellcheck -x password_quality/password_quality.sh"
            }
        }
    }
}
