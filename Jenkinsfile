properties([
        parameters(
                [
                        stringParam(
                                name: 'CHART_NAME',
                                defaultValue: 'datagram'
                        ),
                        stringParam(
                                name: 'APP_VERSION',
                                defaultValue: '0.1.0'
                        ),
                        stringParam(
                                name: 'IMAGE_TAG',
                                defaultValue: ''
                        )
                ]
        )
])

pipeline {

    agent {
        kubernetes {
            label 'deploy-service-pod'
            defaultContainer 'jnlp'
            yaml """
apiVersion: v1
kind: Pod
metadata:
  labels:
    job: deploy-service
spec:
  containers:
  - name: git
    image: alpine/git
    command: ["cat"]
    tty: true
  - name: helm-cli
    image: lachlanevenson/k8s-helm
    command: ["cat"]
    tty: true
"""
        }
    }

    stages {

        stage('Find deployment descriptor') {
            steps {
                container('git') {
                    script {
                        withCredentials([[
                                $class: 'UsernamePasswordMultiBinding',
                                credentialsId: 'rmusin',
                                usernameVariable: 'USERNAME',
                                passwordVariable: 'PASSWORD'
                        ]]) {
                            sh "git clone https://github.com/zanzibeer/${params.CHART_NAME}-deploy.git"
                            dir ("${params.CHART_NAME}-deploy") {
//                                 sh "git checkout ${revision}"
//                                 sh "ls -la"
                            }
                        }
                    }
                }
            }
        }
        stage('Deploy to env') {
            steps {
                container('helm-cli') {
                    script {
                        dir ("${params.CHART_NAME}-deploy") {
                            sh "chmod +x helm/setRevision.sh"
                            sh "chmod +x helm/setImageTags.sh"
                            sh "./helm/setRevision.sh ${params.APP_VERSION}"
                            sh "./helm/setImageTags.sh ${params.IMAGE_TAG}"
//                             def registryIp = sh(script: 'getent hosts registry.kube-system | awk \'{ print $1 ; exit }\'', returnStdout: true).trim()
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