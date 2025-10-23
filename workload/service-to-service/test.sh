#!/bin/bash

echo "=== Testing Service-to-Service Communication ==="

ssh -i ${LOCAL_SSH_KEY_FILE} ubuntu@3.254.212.92 "
echo '1. Checking namespace:'
kubectl get ns bankapp

echo ''
echo '2. Checking pods:'
kubectl get pods -n bankapp -o wide

echo ''
echo '3. Checking services:'
kubectl get svc -n bankapp

echo ''
echo '4. Testing DNS resolution from UI pod:'
kubectl exec -n bankapp deployment/bank-ui -- nslookup bank-api-service.bankapp.svc.cluster.local

echo ''
echo '5. UI logs (service communication):'
kubectl logs -n bankapp deployment/bank-ui --tail=10

echo ''
echo '6. Testing direct curl from UI to API:'
kubectl exec -n bankapp deployment/bank-ui -- curl -s bank-api-service.bankapp.svc.cluster.local
"
