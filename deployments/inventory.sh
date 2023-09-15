#!/bin/bash

if [ "$#" != "2" ]; then
 echo "USAGE: bash inventory.sh [key-pair.pem] [region]"
 exit 300
fi

REGION=$2 

# get environment variables 
WORKER1_PRIVATE_IP=$(aws ec2 describe-instances --filters "Name=tag-value,Values=worker1" "Name=instance-state-name,Values=running" --query 'Reservations[*].Instances[*].[PrivateIpAddress]' --output text --region ${REGION} --profile ${AWS_PROFILE})    
WORKER2_PRIVATE_IP=$(aws ec2 describe-instances --filters "Name=tag-value,Values=worker2" "Name=instance-state-name,Values=running" --query 'Reservations[*].Instances[*].[PrivateIpAddress]' --output text --region ${REGION} --profile ${AWS_PROFILE})    
CONTROLLER1_PRIVATE_IP=$(aws ec2 describe-instances --filters "Name=tag-value,Values=controller1" "Name=instance-state-name,Values=running" --query 'Reservations[*].Instances[*].[PrivateIpAddress]' --output text --region ${REGION} --profile ${AWS_PROFILE})    


# - Confirm the Envrionment variables you've set

echo "CONTROLLER1_PRIVATE_IP=${CONTROLLER1_PRIVATE_IP}" 
echo "WORKER1_PRIVATE_IP=${WORKER1_PRIVATE_IP}"
echo "WORKER2_PRIVATE_IP=${WORKER2_PRIVATE_IP}"
echo "LOCAL_SSH_KEY_FILE=${LOCAL_SSH_KEY_FILE}"


# create ansible inventory file
cat << EOF | tee inventory
[k8s]
controller1     ansible_host=${CONTROLLER1_PRIVATE_IP}    ansible_connection=ssh      ansible_user=ubuntu   ansible_ssh_private_key_file="${LOCAL_SSH_KEY_FILE}"    ansible_become=yes    
worker1         ansible_host=${WORKER1_PRIVATE_IP}  ansible_connection=ssh      ansible_user=ubuntu   ansible_ssh_private_key_file="${LOCAL_SSH_KEY_FILE}"    ansible_become=yes
worker2         ansible_host=${WORKER2_PRIVATE_IP}    ansible_connection=ssh      ansible_user=ubuntu   ansible_ssh_private_key_file="${LOCAL_SSH_KEY_FILE}"    ansible_become=yes

[controllers]
controller1     ansible_host=${CONTROLLER1_PRIVATE_IP}    ansible_connection=ssh      ansible_user=ubuntu   ansible_ssh_private_key_file="${LOCAL_SSH_KEY_FILE}"    ansible_become=yes    

[workers]
worker1         ansible_host=${WORKER1_PRIVATE_IP}  ansible_connection=ssh      ansible_user=ubuntu   ansible_ssh_private_key_file="${LOCAL_SSH_KEY_FILE}"    ansible_become=yes
worker2         ansible_host=${WORKER2_PRIVATE_IP}    ansible_connection=ssh      ansible_user=ubuntu   ansible_ssh_private_key_file="${LOCAL_SSH_KEY_FILE}"    ansible_become=yes
EOF


