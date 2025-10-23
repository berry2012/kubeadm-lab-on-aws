#!/bin/bash

echo "Deploying bankapp service-to-service communication demo..."

scp -i ${LOCAL_SSH_KEY_FILE} *.yaml ubuntu@${ANSIBLE_SERVER_PUBLIC_IP}:~/service-to-service/
ssh -i ${LOCAL_SSH_KEY_FILE} ubuntu@${ANSIBLE_SERVER_PUBLIC_IP} "
mkdir -p ~/service-to-service
cd ~/service-to-service

echo 'Creating namespace...'
kubectl apply -f namespace.yaml

echo 'Deploying backend API...'
kubectl apply -f backend-api.yaml

echo 'Deploying UI frontend...'
kubectl apply -f ui-frontend.yaml

echo 'Waiting for deployments...'
kubectl wait --for=condition=available --timeout=300s deployment/bank-api -n bankapp
kubectl wait --for=condition=available --timeout=300s deployment/bank-ui -n bankapp

echo 'Deployment complete!'
echo 'Check service communication with: kubectl logs -f deployment/bank-ui -n bankapp'
"
