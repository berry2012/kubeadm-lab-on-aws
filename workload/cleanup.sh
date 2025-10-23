#!/bin/bash

echo "Cleaning up WordPress and MySQL deployment..."

ssh -i ${LOCAL_SSH_KEY_FILE} ubuntu@${ANSIBLE_SERVER_PUBLIC_IP} "
echo 'Deleting Kubernetes resources...'
kubectl delete deployment wordpress mysql
kubectl delete service wordpress-service mysql-service
kubectl delete pvc wordpress-pvc mysql-pvc
kubectl delete pv wordpress-pv mysql-pv
kubectl delete secret mysql-secret
kubectl delete storageclass local-storage

echo 'Removing temporary directories from worker nodes...'
ssh k8s-worker1 'sudo rm -rf /tmp/mysql-data /tmp/wordpress-data'
ssh k8s-worker2 'sudo rm -rf /tmp/mysql-data /tmp/wordpress-data'

echo 'Cleanup complete!'
"

echo "All resources have been removed from the cluster and worker nodes."
