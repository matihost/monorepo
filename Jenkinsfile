#!/usr/bin/env groovy
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
  stages {
    stage('Checkout') {
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
      }
    }
  }
}

