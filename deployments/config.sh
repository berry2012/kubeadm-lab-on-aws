#!/bin/bash

if [ "$#" != "2" ]; then
 echo "USAGE: bash config.sh [key-pair.pem] [region]"
 exit 300
fi

REGION=eu-west-1 # update this with your AWS environment
# get variables - if you are using AWS profile other than default, substitue it in the commands below:

WORKER1_PRIVATE_IP=$(aws ec2 describe-instances --filters "Name=tag-value,Values=worker1" "Name=instance-state-name,Values=running" --query 'Reservations[*].Instances[*].[PrivateIpAddress]' --output text --region ${REGION} --profile default)    
WORKER2_PRIVATE_IP=$(aws ec2 describe-instances --filters "Name=tag-value,Values=worker2" "Name=instance-state-name,Values=running" --query 'Reservations[*].Instances[*].[PrivateIpAddress]' --output text --region ${REGION} --profile default)    
CONTROLLER1_PRIVATE_IP=$(aws ec2 describe-instances --filters "Name=tag-value,Values=controller1" "Name=instance-state-name,Values=running" --query 'Reservations[*].Instances[*].[PrivateIpAddress]' --output text --region ${REGION} --profile default)    

cat << EOF | tee config
Host k8s-controller
    HostName ${CONTROLLER1_PRIVATE_IP}
    User ubuntu
    IdentityFIle ${LOCAL_SSH_KEY_FILE}

Host k8s-worker1
    HostName ${WORKER1_PRIVATE_IP}
    User ubuntu
    IdentityFIle ${LOCAL_SSH_KEY_FILE} 

Host k8s-worker2
    HostName ${WORKER2_PRIVATE_IP}
    User ubuntu
    IdentityFIle ${LOCAL_SSH_KEY_FILE}       
EOF

