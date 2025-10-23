#!/bin/bash

echo "Cleaning up bankapp service-to-service demo..."

ssh -i ${LOCAL_SSH_KEY_FILE} ubuntu@${ANSIBLE_SERVER_PUBLIC_IP} "
echo 'Deleting bankapp namespace and all resources...'
kubectl delete namespace bankapp

echo 'Cleanup complete!'
"
