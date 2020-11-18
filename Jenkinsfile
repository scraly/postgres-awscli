@Library(['Common']) _

IMAGE_NAME = 'postgres-awscli'
UNIQUE_VERSION = UUID.randomUUID().toString()
STABLE_BRANCH = 'master'

pipeline {
  agent {
    label 'default'
  }

  options {
    ansiColor('xterm')
    timeout(time: 10, unit: 'MINUTES')
  }

  environment {
    // Set version under the schemed format (method from shared lib)
    SCHEMED_VERSION = getSchemedVersion()
    // Project Name in Harbor
    PROJECT_NAME = 'tiny_ehorizon'
    // Password for REAL SUPER IMPORTANT Project in Harbor like TinyEH
    REPO_CD_PUSH_CREDENTIALS_ID = 'harbor-robot-tinyeh'
  }

  stages {
    stage('Build info') {
      steps {
        sh "ls -lah"
        sh "docker version"
      }
    }
    
    stage('Build image') {
      steps {
        sh "docker build -t ${IMAGE_NAME}:${UNIQUE_VERSION} ."
      }
    }

    stage('Push image to DEV registry') {
      // when { anyOf { branch "${STABLE_BRANCH}"; changeRequest target: "${STABLE_BRANCH}" } }
      when { anyOf { branch "${STABLE_BRANCH}" } }
      steps {
        withCredentials([[$class: 'UsernamePasswordMultiBinding', credentialsId: REPO_CD_PUSH_CREDENTIALS_ID, usernameVariable: 'USERNAME', passwordVariable: 'PASSWORD']]) {
          sh "docker tag ${IMAGE_NAME}:${UNIQUE_VERSION} ${REPO_CD_HOSTNAME}/${PROJECT_NAME}/${IMAGE_NAME}:${SCHEMED_VERSION}"
          sh "docker tag ${IMAGE_NAME}:${UNIQUE_VERSION} ${REPO_CD_HOSTNAME}/${PROJECT_NAME}/${IMAGE_NAME}:latest"
          sh "echo \"\${PASSWORD}\" | docker login -u \"\${USERNAME}\" --password-stdin \"\${REPO_CD_HOSTNAME}\""
          sh "docker push ${REPO_CD_HOSTNAME}/${PROJECT_NAME}/${IMAGE_NAME}:${SCHEMED_VERSION}"
          sh "docker push ${REPO_CD_HOSTNAME}/${PROJECT_NAME}/${IMAGE_NAME}:latest"
        }
      }
    }
  }
  
  post {
    failure {
      script {
        if (env.BRANCH_NAME == "${STABLE_BRANCH}" || env.BRANCH_NAME.startsWith('PR')) {
          slackSend color: 'danger', channel: '#tiny-ehorizon-builds', message: ":jenkins-devil: Jenkins ${env.JOB_NAME} Job : Failed ! (<${env.BUILD_URL}|#${env.BUILD_NUMBER}>) :jenkins-devil:"
        }
      }
    }
  }
}
