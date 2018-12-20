pipeline {
  agent any
  stages {
    stage('M1') {
      parallel {
        stage('M1') {
          steps {
            sh 'echo test'
            sh 'echo test'
          }
        }
        stage('M2') {
          steps {
            sh 'echo test 3'
          }
        }
      }
    }
    stage('M2') {
      steps {
        sh 'echo test 33'
      }
    }
  }
}