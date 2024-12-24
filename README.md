# Kubeadm-lab-on-aws
**Setup Kubernetes Lab on AWS for CKA, CKAD, CKS Exam or Kubernetes Practise**

*This is K8s Lab - CKA, CKAD, and CKS Exam*

# Pre-requisites:
- [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html) 
- [AWS Account](https://aws.amazon.com/premiumsupport/knowledge-center/create-and-activate-aws-account/)
- [Key Pair](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/create-key-pairs.html)

## Cluster Details -  4 servers

- 1 control plane
- 2 worker nodes
- 1 Kubectl Client

## Default Kubernetes Version

v1.31

## Node Details

- All the provisioned instances run the same OS

```bash
ubuntu@ip-10-192-10-110:~$ cat /etc/os-release 
NAME="Ubuntu"
VERSION="20.04.4 LTS (Focal Fossa)"
ID=ubuntu
ID_LIKE=debian
PRETTY_NAME="Ubuntu 20.04.4 LTS"
VERSION_ID="20.04"
HOME_URL="https://www.ubuntu.com/"
SUPPORT_URL="https://help.ubuntu.com/"
BUG_REPORT_URL="https://bugs.launchpad.net/ubuntu/"
PRIVACY_POLICY_URL="https://www.ubuntu.com/legal/terms-and-policies/privacy-policy"
VERSION_CODENAME=focal
UBUNTU_CODENAME=focal
```

## Getting Started

## Step 1: Deploy the Infrastructure on AWS

Follow any of the options below:

**Option A: Deploy the Infrastructure with CloudFormation from AWS Console:**

- Clone the repo
- Goto AWS Console > Choose Region (e.g. eu-west-1) > CloudFormation > Create Stack
- Use the CF Yaml template in `infrastructure/k8s_aws_instances.yml`
- See image below:

![Create Infrastructure](./images/CF-infrastructure.png)

**Option B: Deploy the Infrastructure with CloudFormation from AWS CLI:**

- Clone the repo

```bash
git clone repo
cd kubeadm-lab-on-aws
```

- Define your environment variables

```bash
export REGION="eu-west-1"
export key_pair="my-EC2-key-name"
```

**Note: key_pair is your key pair and should already be created in AWS EC2.**

- Create the infrastructure for your stack

```bash
aws cloudformation create-stack --stack-name kubeadm-lab --template-body file://infrastructure/k8s_aws_instances.yml --parameters ParameterKey=EnvironmentName,ParameterValue=k8s ParameterKey=KeyName,ParameterValue=${key_pair} --capabilities CAPABILITY_NAMED_IAM --region ${REGION}

```

- Check stack status for CREATE_COMPLETE. Takes about 3mins

```bash
aws cloudformation describe-stacks --stack-name kubeadm-lab --query 'Stacks[].StackStatus' --region ${REGION} --output text
aws cloudformation wait stack-create-complete --stack-name kubeadm-lab
```

## Step 2: Configuring the environment

- Define your global variables

```bash
export LOCAL_SSH_KEY_FILE="~/.ssh/my-EC2-key-name.pem"
export REGION="eu-west-1"
```

**Note: By default, the AWS CLI uses the settings found in the profile named default. To use alternate settings, you can [create and reference additional profiles](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-files.html).**

- Confirm the instances created and the Public IP of the Ansible controller server

```bash
aws ec2 describe-instances --filters "Name=tag:project,Values=k8s-kubeadm" "Name=instance-state-name,Values=running" --query 'Reservations[*].Instances[*].[Placement.AvailabilityZone, State.Name, InstanceId, PrivateIpAddress, PublicIpAddress, [Tags[?Key==`Name`].Value] [0][0]]' --output text --region ${REGION}
```

- Define your Ansible server environment variable. if you are using AWS profile other than default, substitue it in the commands below:

```bash
export ANSIBLE_SERVER_PUBLIC_IP="$(aws ec2 describe-instances --filters "Name=tag-value,Values=ansible_controller_kubeadm_lab" "Name=instance-state-name,Values=running" --query 'Reservations[*].Instances[*].[PublicIpAddress]' --output text --region ${REGION})"
```

- Transfer your SSH key to the Ansible Server. This will be need in the Ansible Inventory file.
  
```bash
echo "scp -i ${LOCAL_SSH_KEY_FILE} ${LOCAL_SSH_KEY_FILE} ubuntu@${ANSIBLE_SERVER_PUBLIC_IP}:~/.ssh/" 
```

- Inspect and execute the output of the command generated above. Replace **my-EC2-key-name.pem** with your own values

```bash
scp -i ~/.ssh/my-EC2-key-name.pem ~/.ssh/my-EC2-key-name.pem ubuntu@XX.XX.XX.XX:~/.ssh/
```

- To Create inventory file. Edit the inventory.sh and update the REGION if different from `eu-west-1`.

- View the inventory file and update it according to your AWS environment setup
  
```bash
vi deployments/inventory.sh
```

- Proceed with the commands below:
  
```bash
chmod +x deployments/inventory.sh
bash deployments/inventory.sh ${LOCAL_SSH_KEY_FILE} ${REGION}
chmod +x deployments/config.sh 
bash deployments/config.sh ${LOCAL_SSH_KEY_FILE} ${REGION}
```

- Transfer all playbooks in deployments/playbooks to the ansible server

```bash
cd deployments
scp -i ${LOCAL_SSH_KEY_FILE} deployment.yml setup.sh ../inventory ../config *.cfg ubuntu@${ANSIBLE_SERVER_PUBLIC_IP}:~
scp -i ${LOCAL_SSH_KEY_FILE} ../config ubuntu@${ANSIBLE_SERVER_PUBLIC_IP}:~/.ssh/config
```

- Connect to the Ansible Server
  
```bash
ssh -i ${LOCAL_SSH_KEY_FILE} ubuntu@${ANSIBLE_SERVER_PUBLIC_IP}
```

- Your ssh key copied to the Ansible server

```bash
chmod 400 ~/.ssh/key_name.pem  
```

- After building the inventory file, test if all hosts are reachable

1. List all hosts to confirm that the inventory file is properly configured

```bash
ansible all --list-hosts -i inventory
```

Expected output:

```bash
  hosts (5):
    controller1
    worker1
    worker2
```

2. Test ping on all the hosts

```bash
ansible -i inventory k8s -m ping 
```

## Deploy with Ansible

```bash
ansible-playbook -i inventory -v deployment.yml
```

## Final Result

```bash
TASK [Ansible Host Kubectl Commands] *********************************************************************************************************************************************************************************************************************************************************************
ok: [localhost] => {
    "msg": [
        "NAME             STATUS   ROLES           AGE     VERSION",
        "k8s-controller   Ready    control-plane   2m26s   v1.31.4",
        "k8s-worker1      Ready    <none>          73s     v1.31.4",
        "k8s-worker2      Ready    <none>          69s     v1.31.4"
    ]
}
 
```

## Test Kubectl Commands on the Ansible Controller Server

```bash
ubuntu@ip-10-192-10-189:~$ kubectl get nodes
NAME             STATUS   ROLES           AGE     VERSION
k8s-controller   Ready    control-plane   3m19s   v1.31.4
k8s-worker1      Ready    <none>          2m6s    v1.31.4
k8s-worker2      Ready    <none>          2m2s    v1.31.4
```

## Test Kubectl Commands on the Kubernetes Controller

```bash
ubuntu@ip-10-192-10-189:~$ ssh k8s-controller

ubuntu@k8s-controller:~$ kubectl get nodes
NAME             STATUS   ROLES           AGE     VERSION
k8s-controller   Ready    control-plane   5m16s   v1.31.4
k8s-worker1      Ready    <none>          4m3s    v1.31.4
k8s-worker2      Ready    <none>          3m59s   v1.31.4
```

## Clean Up

To Delete the AWS CloudFormation Stack

```bash
aws cloudformation delete-stack --stack-name kubeadm-lab
```


Check if the AWS CloudFormation Stack still exist to confirm deletion

```bash
aws cloudformation list-stacks --stack-status-filter DELETE_COMPLETE --region ${REGION} --query 'StackSummaries[*].{Name:StackName,Date:CreationTime,Status:StackStatus}' --output text | grep kubeadm
```