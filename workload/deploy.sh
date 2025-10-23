#!/bin/bash

echo "Creating temporary directories on worker nodes..."
scp -i ${LOCAL_SSH_KEY_FILE} *.yaml ubuntu@${ANSIBLE_SERVER_PUBLIC_IP}:~/
ssh -i ${LOCAL_SSH_KEY_FILE} ubuntu@${ANSIBLE_SERVER_PUBLIC_IP} "
echo 'Creating directories on k8s-worker1...'
ssh k8s-worker1 'sudo mkdir -p /tmp/mysql-data /tmp/wordpress-data && sudo chmod 777 /tmp/mysql-data /tmp/wordpress-data'

echo 'Creating directories on k8s-worker2...'
ssh k8s-worker2 'sudo mkdir -p /tmp/mysql-data /tmp/wordpress-data && sudo chmod 777 /tmp/mysql-data /tmp/wordpress-data'

echo 'Applying Kubernetes manifests...'
kubectl apply -f storageclass.yaml
kubectl apply -f mysql-secret.yaml
kubectl apply -f mysql-pv.yaml
kubectl apply -f mysql-deployment.yaml
kubectl apply -f wordpress-pv.yaml
kubectl apply -f wordpress-deployment.yaml

echo 'Waiting for deployments to be ready...'
kubectl wait --for=condition=available --timeout=300s deployment/mysql
kubectl wait --for=condition=available --timeout=300s deployment/wordpress

echo 'Deployment complete!'
echo 'WordPress is accessible at: http://${ANSIBLE_SERVER_PUBLIC_IP}:30080'
"

kubectl delete -f storageclass.yaml 
kubectl delete -f mysql-secret.yaml
# patch pv and remove finalizers
kubectl patch pv mysql-pv -p '{"metadata":{"finalizers":[]}}' --type=merge
kubectl delete -f mysql-pv.yaml --force
kubectl delete -f mysql-deployment.yaml
kubectl patch pv wordpress-pv -p '{"metadata":{"finalizers":[]}}' --type=merge
# patch pvc and remove finalizers
kubectl patch pvc wordpress-pvc -p '{"metadata":{"finalizers":[]}}' --type=merge
kubectl delete -f wordpress-pv.yaml --force
kubectl delete -f wordpress-deployment.yaml
