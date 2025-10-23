#!/bin/bash

echo "Cleaning up Global Multi-Location App..."

ssh -i ${LOCAL_SSH_KEY_FILE} ubuntu@${ANSIBLE_SERVER_PUBLIC_IP} "
echo 'Deleting geo namespace and all resources...'
kubectl delete namespace geo

echo 'Cleanup complete!'
"
