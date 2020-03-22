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
        stage('Build :: Golang') {
          steps {
            container("golang"){
              dir("go"){
                echo "Building ${pwd()}..."
                script {
                  def GOPATH = sh(script: 'go env GOPATH', returnStdout: true).trim()
                  def PROJECT = "github.com/matihost/learning"
                  def REPOSITORY = "go"
                  def CMD_PACKAGE_NAME = "language"
                  def DIR = pwd()
                  def TEMP_GO_PATH = "${DIR}/.build-workspace"
                  sh """
                    curl https://raw.githubusercontent.com/golang/dep/master/install.sh | sh
                    mkdir -p ${GOPATH}/src/${PROJECT} && \
                    cd ${GOPATH}/src/${PROJECT} && \
                    (rm -f ${REPOSITORY} && ln -s ${DIR} ${REPOSITORY})
                    cd ${GOPATH}/src/${PROJECT}/${REPOSITORY} && \
                    (ls Gopkg.toml >/dev/null 2>&1 || dep init) && \
                    dep ensure -update
	                  cd ${GOPATH}/src/${PROJECT}/${REPOSITORY} && \
                    cd cmd/${CMD_PACKAGE_NAME} && \
                    go build && \
                    cd ${GOPATH}/src/${PROJECT}/${REPOSITORY}/pkg/language && \
	                  go test                 
                  """     
                }                    
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
      }
    }
  }
}

