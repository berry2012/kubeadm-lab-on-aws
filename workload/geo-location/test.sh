#!/bin/bash

echo "=== Testing Global Multi-Location App ==="

ssh -i ~/.ssh/aws-wale.pem ubuntu@${ANSIBLE_SERVER_PUBLIC_IP} "
echo '1. Checking namespace and pods:'
kubectl get pods,svc -n geo -o wide

echo ''
echo '2. Testing DNS resolution:'
kubectl exec -n geo deployment/globalapp -- nslookup south.geo.svc.cluster.local
kubectl exec -n geo deployment/globalapp -- nslookup north.geo.svc.cluster.local

echo ''
echo '3. Testing service communication from globalapp:'
kubectl logs -n geo deployment/globalapp --tail=10

echo ''
echo '4. Testing direct service calls:'
kubectl exec -n geo deployment/globalapp -- curl -s south.geo.svc.cluster.local
echo ''
kubectl exec -n geo deployment/globalapp -- curl -s north.geo.svc.cluster.local

echo ''
echo '5. Testing proxy routes:'
kubectl exec -n geo deployment/globalapp -- curl -s localhost/south
echo ''
kubectl exec -n geo deployment/globalapp -- curl -s localhost/north
"

echo ""
echo "6. External access test:"
echo "Testing GlobalApp routes..."
curl -s http://${ANSIBLE_SERVER_PUBLIC_IP}:30090/ | grep -o '<h1>.*</h1>' || echo "Main route test failed"
curl -s http://${ANSIBLE_SERVER_PUBLIC_IP}:30090/south | grep -o '<h1>.*</h1>' || echo "South route test failed"  
curl -s http://${ANSIBLE_SERVER_PUBLIC_IP}:30090/north | grep -o '<h1>.*</h1>' || echo "North route test failed"

echo ""
echo "=== Access URLs ==="
echo "Main (load balanced): http://${ANSIBLE_SERVER_PUBLIC_IP}:30090/"
echo "South service: http://${ANSIBLE_SERVER_PUBLIC_IP}:30090/south"
echo "North service: http://${ANSIBLE_SERVER_PUBLIC_IP}:30090/north"
