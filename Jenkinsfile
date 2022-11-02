properties([
        parameters(
                [
                        stringParam(
                                name: 'CHART_NAME',
                                defaultValue: 'datagram'
                        ),
                        stringParam(
                                name: 'APP_VERSION',
                                defaultValue: ''
                        ),
                        stringParam(
                                name: 'IMAGE_TAG',
                                defaultValue: ''
                        )
                ]
        )
])

pipeline {

    options {
            ansiColor('xterm')
            skipDefaultCheckout true
        }

    agent {
        kubernetes {
            yamlFile 'builder.yaml'
        }
    }

    stages {

        stage('Checkout') {
            steps {
                script {
                    if (IMAGE_TAG=="") {
                        error("Check entered parameters values: IMAGE_TAG or APP_VERSION. They must not be empty!")
                        currentBuild.result = 'ABORTED'
                    }
                    if (APP_VERSION=="") {
                        error("Check entered parameters values: IMAGE_TAG or APP_VERSION. They must not be empty!")
                        currentBuild.result = 'ABORTED'
                    }
                }
            }
        }



        stage('Clone git repo') {
            steps {
                container('git') {
                    script {
                            sh "git clone https://github.com/zanzibeer/${params.CHART_NAME}_deploy.git"
                    }
                }
            }
        }
            
        stage('Deploy to env') {
            steps {
                container('helm-cli') {
                    script {
                        dir ("${params.CHART_NAME}_deploy") {
                            sh "chmod +x helm/setRevision.sh"
                            sh "chmod +x helm/setImageTags.sh"
                            sh "./helm/setRevision.sh ${params.APP_VERSION}"
                            sh "./helm/setImageTags.sh ${params.IMAGE_TAG}"
                            sh "helm dependency build helm/datagram"
                            sh "helm upgrade ${params.CHART_NAME} helm/datagram --install --namespace neoflex-${params.CHART_NAME} --create-namespace \
                            --set postgresql.auth.password=\"chAngE_Me\""
                        }
                    }
                }
            }
        }
    }
}
