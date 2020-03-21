pipeline {
  agent {
    kubernetes {
      yaml """
apiVersion: v1
kind: Pod
metadata:
  labels:
    purpose: ci
spec:
  containers:
  - name: maven-jdk11
    image: maven:3-jdk-11
    workingDir: /workdir
    command:
    - sleep
    args:
    - infinity
    volumeMounts:
    - mountPath: /workdir
      name: workdir    
  - name: golang
    image: mirror.gcr.io/library/golang:latest
    workingDir: /workdir
    command:
    - sleep
    args:
    - infinity
    volumeMounts:
    - mountPath: /workdir
      name: workdir    
  - name: python
    image: mirror.gcr.io/library/python:3.7
    workingDir: /workdir
    command:
    - cat
    tty: true
    volumeMounts:
    - mountPath: /workdir
      name: workdir    
  - name: rust
    image: rust
    workingDir: /workdir
    command:
    - cat
    tty: true
    volumeMounts:
    - mountPath: /workdir
      name: workdir   
  volumes:
  - name: workdir
    emptyDir: {}
"""
    }
  }
  environment {
    WORK_DIR = '/workdir'
  }
  stages {
    stage('Checkout') {
      steps {
          checkout scm
          input 'stop'
      }
    }
    stage('Build Java') {
      steps {
        container("maven-jdk11"){
          dir("${WORK_DIR}"){
            sh """
            mvn -s .mvn/settings.xml clean install
            """
          }    
        }
      }
    }
  }
}

