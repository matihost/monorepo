#!/usr/bin/env groovy
//TODO add kaniko, add ansible, get test artifacts from pytest, golang?
pipeline {
  agent {
    kubernetes {
      label "learning-${env.BRANCH_NAME}" // subsequent builds from the same branch will reuse pods
      idleMinutes 60 // pod will be available to reuse for 1 h
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
    command:
    - sleep
    args:
    - infinity
    volumeMounts:
    - mountPath: /home/jenkins/agent
      name: workspace-volume
  - name: golang
    image: mirror.gcr.io/library/golang:latest
    command:
    - sleep
    args:
    - infinity
    volumeMounts:
    - mountPath: /home/jenkins/agent
      name: workspace-volume
  - name: python
    image: mirror.gcr.io/library/python:3.7
    command:
    - cat
    tty: true
    volumeMounts:
    - mountPath: /home/jenkins/agent
      name: workspace-volume
  - name: rust
    image: rust
    command:
    - cat
    tty: true
    volumeMounts:
    - mountPath: /home/jenkins/agent
      name: workspace-volume
"""
    }
  }
  options{
    buildDiscarder(logRotator(numToKeepStr: '10'))
    timeout(time: 1, unit: 'HOURS')
    skipDefaultCheckout()  // to avoid auto checkout sources matching Jenkinsfile, if skipped pipeline needs to call: checkout scm
    skipStagesAfterUnstable()
    parallelsAlwaysFailFast()
    timestamps()
  }
  triggers {
    pollSCM('H/10 * * * 1-5')
  }
  stages {
    stage('Checkout sources') {
      steps {
        checkout scm
      }
    }
    stage('Build') {
      parallel {
        stage('Build :: Java') {
          steps {
              container("maven-jdk11"){
                dir("java"){
                  echo "Building ${pwd()}..."
                  sh """
                  mvn -s .mvn/settings.xml clean install
                  """
                }   
              }
          }
          post{
            always {
              dir("java"){
                archiveArtifacts artifacts: '**/target/*.jar', fingerprint: true
                junit '**/target/surefire-reports/*.xml'     
              }
            }
          }
        }
        stage('Build :: Project Euler') {
          steps {
            container("maven-jdk11"){
              dir("algorithms/project-euler"){
                echo "Building ${pwd()}..."
                sh """
                mvn -s .mvn/settings.xml clean install
                """                         
              }   
            }
          }
          post{
            always {
              dir("algorithms/project-euler"){
                archiveArtifacts artifacts: '**/target/*.jar', fingerprint: true
              }
            }
          }      
        }
        stage('Build :: Golang') {
          steps {
            container("golang"){
              dir("go"){
                echo "Building ${pwd()}..."
                sh """
                  curl https://raw.githubusercontent.com/golang/dep/master/install.sh | sh
                  make build             
                """
              }   
            }
          }
          post{
            always {
              dir("go"){
                archiveArtifacts artifacts: '**/language', fingerprint: true
              }
            }
          }
        }
        stage('Build :: Rust') {
          steps {
            container("rust"){
              dir("rust/guessing_game"){
                echo "Building ${pwd()}..."
                sh """
                  make build             
                """
              }   
            }
          }
        }
        stage('Build :: Python') {
          steps {
            container("python"){
              dir("python/apps/exchange-rate"){
                echo "Building ${pwd()}..."
                sh """
                  pip3 install pipenv
                  make lint
                  make build
                  make test
                  make run
                """
              }   
            }
          }
        }             
      }
    }
  }
}
