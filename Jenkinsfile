// Jenkinsfile for Cakes n Bakes 365
// This pipeline builds and deploys the app using Docker Compose

pipeline {
  agent any

  environment {
    DOCKER_BUILDKIT = "1"
    COMPOSE_DOCKER_CLI_BUILD = "1"
  }

  stages {
    // Step 1: Get the code
    stage("Checkout") {
      steps {
        checkout scm
      }
    }

    // Step 2: Set up the .env file for the build
    stage("Prepare Env") {
      steps {
        sh """
          set -euo pipefail
          cp .env.ci.example .env
          chmod 600 .env
        """
      }
    }

    // Step 3: Check backend code for syntax errors
    stage("Backend Check") {
      steps {
        sh """
          set -euo pipefail
          npm ci --prefix backend
          find backend/src -type f -name "*.js" -print0 | xargs -0 -r -n1 node --check
        """
      }
    }

    // Step 4: Build all Docker images
    stage("Build") {
      steps {
        sh """
          set -euo pipefail
          docker compose build --pull
        """
      }
    }

    // Step 5: Deploy using docker compose
    stage("Deploy") {
      steps {
        sh """
          set -euo pipefail
          docker compose up -d --build --remove-orphans
        """
      }
    }

    // Step 6: Run smoke tests to check if everything is working
    stage("Smoke Test") {
      steps {
        sh """
          set -euo pipefail
          ./scripts/smoke-test.sh
        """
      }
    }
  }

  // Always show container status, show logs if something failed
  post {
    always {
      sh """
        set +e
        docker compose ps
      """
    }
    failure {
      sh """
        set +e
        docker compose logs --tail=120
      """
    }
  }
}
