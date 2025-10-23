#!/bin/bash

echo "Deploying Global Multi-Location App with Nginx Proxy..."

scp -i ${LOCAL_SSH_KEY_FILE} *.yaml ubuntu@${ANSIBLE_SERVER_PUBLIC_IP}:~/geo-location/
ssh -i ${LOCAL_SSH_KEY_FILE} ubuntu@${ANSIBLE_SERVER_PUBLIC_IP} "
mkdir -p ~/geo-location
cd ~/geo-location

echo 'Creating namespace...'
kubectl apply -f namespace.yaml

echo 'Creating nginx configuration...'
kubectl apply -f nginx-config.yaml

echo 'Deploying south service...'
kubectl apply -f south-service.yaml

echo 'Deploying north service...'
kubectl apply -f north-service.yaml

echo 'Deploying globalapp frontend...'
kubectl apply -f globalapp-frontend.yaml

echo 'Waiting for deployments...'
kubectl wait --for=condition=available --timeout=300s deployment/south -n geo
kubectl wait --for=condition=available --timeout=300s deployment/north -n geo
kubectl wait --for=condition=available --timeout=300s deployment/globalapp -n geo

echo 'Deployment complete!'
echo 'GlobalApp is accessible at: http://${ANSIBLE_SERVER_PUBLIC_IP}:30090'
echo 'Routes:'
echo '  / - Load balanced between north and south'
echo '  /north - Direct to north service'
echo '  /south - Direct to south service'
"
