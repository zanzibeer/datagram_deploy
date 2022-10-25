properties([
        parameters(
                [
                        stringParam(
                                name: 'CHART',
                                defaultValue: 'datagram'
                        ),
                        stringParam(
                                name: 'VERSION',
                                defaultValue: '0.1.0'
                        ),
                        stringParam(
                                name: 'TAG',
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
//                         def revision = params.VERSION.substring(0, 7)
//                         def revision = 0.1.0
                        withCredentials([[
                                $class: 'UsernamePasswordMultiBinding',
                                credentialsId: 'rmusin',
                                usernameVariable: 'USERNAME',
                                passwordVariable: 'PASSWORD'
                        ]]) {
                            sh "git clone https://$USERNAME:$PASSWORD@github.com/zanzibeer/${params.CHART}-deploy.git"
                            dir ("${params.CHART}") {
//                                 sh "git checkout ${revision}"
//                                 sh "echo ${params.GIT_REPO}"
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
                        dir ("${params.CHART}") {
                            sh "chmod +x helm/setRevision.sh"
                            sh "chmod +x helm/setImageTags.sh"
                            sh "./helm/setRevision.sh ${params.VERSION}"
                            sh "./helm/setImageTags.sh ${params.TAG}"
//                             def registryIp = sh(script: 'getent hosts registry.kube-system | awk \'{ print $1 ; exit }\'', returnStdout: true).trim()
                            sh "helm dependency build helm/datagram"
                            sh "helm upgrade ${params.CHART} helm/datagram --install --namespace neoflex-${params.CHART} --create-namespace \
                            --set postgresql.auth.password=\"chAngE_Me\""
                        }
                    }
                }
            }
        }
    }
}