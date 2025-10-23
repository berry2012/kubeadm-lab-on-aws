#!/bin/bash

echo "=== Testing WordPress and MySQL Deployment ==="
echo ""

ssh -i ${LOCAL_SSH_KEY_FILE} ubuntu@${ANSIBLE_SERVER_PUBLIC_IP} "
echo '1. Checking pod status:'
kubectl get pods -o wide

echo ''
echo '2. Checking services:'
kubectl get services

echo ''
echo '3. Checking persistent volumes:'
kubectl get pv,pvc

echo ''
echo '4. Testing MySQL connectivity:'
kubectl exec -it deployment/mysql -- mysql -u wordpress -pwordpresspass -e 'SHOW DATABASES;'

echo ''
echo '5. WordPress logs (last 10 lines):'
kubectl logs deployment/wordpress --tail=10

echo ''
echo '6. MySQL logs (last 10 lines):'
kubectl logs deployment/mysql --tail=10
"

echo ""
echo "7. Testing WordPress connectivity:"
curl -I http://${ANSIBLE_SERVER_PUBLIC_IP}:30080

echo ""
echo "=== Access WordPress ==="
echo "Open your browser and go to: http://${ANSIBLE_SERVER_PUBLIC_IP}:30080"
