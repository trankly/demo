pipeline {
    agent none
    stages {
        stage('Build') {
            agent {
                kubernetes {
                    cloud 'yetee'
                    yaml """
                        kind: Pod
                        metadata:
                          name: kaniko
                        spec:
                          containers:
                          - name: kaniko
                            image: gcr.io/kaniko-project/executor:debug-539ddefcae3fd6b411a95982a830d987f4214251
                            imagePullPolicy: Always
                            command:
                            - cat
                            tty: true
                            volumeMounts:
                              - name: ecr-credentials
                                mountPath: /kaniko/.docker
                          volumes:
                            - name: ecr-credentials
                              configMap:
                                name: ecr-credentials
                        """
                }
            }
            steps {
                container(name: 'kaniko') {
                    withCredentials([string(credentialsId: 'ecr_demo', variable: 'ECR_REPO')]) {
                        sh '''
                        /kaniko/executor --dockerfile `pwd`/Dockerfile --context `pwd` --destination=$ECR_REPO:latest --destination=$ECR_REPO:v$BUILD_NUMBER
                        '''
                    }
                }
            }
        }
        stage('Deploy') {
            agent {
                label 'docker'
            }
            steps {
                withCredentials([string(credentialsId: 'kube_url', variable: 'KUBE_URL'), string(credentialsId: 'jenkins', variable: 'KUBE_TOKEN'), string(credentialsId: 'ecr_demo', variable: 'ECR_REPO')]) {
                    sh '''#!/bin/bash -xe
                    kubectl config set-cluster k8s --server=$KUBE_URL --insecure-skip-tls-verify=true
                    kubectl config set-credentials jenkins --token $KUBE_TOKEN
                    kubectl config set-context default --cluster=k8s --user=jenkins
                    kubectl config use-context default
                    sed -i "s~{IMAGE}~$ECR_REPO~g" `pwd`/demo.yaml
                    kubectl apply -f `pwd`/demo.yaml
                    '''
                }
            }
        }
    }
}