#!/bin/bash

REGION=eu-west-1 # update this with your AWS environment
SSH_KEY_FILE="~/.ssh/aws.pem"  # update this with your key

# get variables - if you are using AWS profile other than default, substitue it in the commands below:
WORKER1_PRIVATE_IP=$(aws ec2 describe-instances --filters "Name=tag-value,Values=worker1" "Name=instance-state-name,Values=running" --query 'Reservations[*].Instances[*].[PrivateIpAddress]' --output text --region ${REGION} --profile default)    
WORKER2_PRIVATE_IP=$(aws ec2 describe-instances --filters "Name=tag-value,Values=worker2" "Name=instance-state-name,Values=running" --query 'Reservations[*].Instances[*].[PrivateIpAddress]' --output text --region ${REGION} --profile default)    
CONTROLLER1_PRIVATE_IP=$(aws ec2 describe-instances --filters "Name=tag-value,Values=controller1" "Name=instance-state-name,Values=running" --query 'Reservations[*].Instances[*].[PrivateIpAddress]' --output text --region ${REGION} --profile default)    


# - Confirm the Envrionment variables you've set

echo "CONTROLLER1_PRIVATE_IP=${CONTROLLER1_PRIVATE_IP}" 
echo "WORKER1_PRIVATE_IP=${WORKER1_PRIVATE_IP}"
echo "WORKER2_PRIVATE_IP=${WORKER2_PRIVATE_IP}"
echo "SSH_KEY_FILE=${SSH_KEY_FILE}"


# create ansible inventory file
cat << EOF | tee inventory
[k8s]
controller1     ansible_host=${CONTROLLER1_PRIVATE_IP}    ansible_connection=ssh      ansible_user=ubuntu   ansible_ssh_private_key_file="${SSH_KEY_FILE}"    ansible_become=yes    
worker1         ansible_host=${WORKER1_PRIVATE_IP}  ansible_connection=ssh      ansible_user=ubuntu   ansible_ssh_private_key_file="${SSH_KEY_FILE}"    ansible_become=yes
worker2         ansible_host=${WORKER2_PRIVATE_IP}    ansible_connection=ssh      ansible_user=ubuntu   ansible_ssh_private_key_file="${SSH_KEY_FILE}"    ansible_become=yes

[controllers]
controller1     ansible_host=${CONTROLLER1_PRIVATE_IP}    ansible_connection=ssh      ansible_user=ubuntu   ansible_ssh_private_key_file="${SSH_KEY_FILE}"    ansible_become=yes    

[workers]
worker1         ansible_host=${WORKER1_PRIVATE_IP}  ansible_connection=ssh      ansible_user=ubuntu   ansible_ssh_private_key_file="${SSH_KEY_FILE}"    ansible_become=yes
worker2         ansible_host=${WORKER2_PRIVATE_IP}    ansible_connection=ssh      ansible_user=ubuntu   ansible_ssh_private_key_file="${SSH_KEY_FILE}"    ansible_become=yes
EOF
