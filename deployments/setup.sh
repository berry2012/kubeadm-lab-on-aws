#!/bin/bash


# Create configuration file for containerd:
cat <<EOF | sudo tee /etc/modules-load.d/containerd.conf
overlay
br_netfilter
EOF

# Load modules:
sudo modprobe overlay
sudo modprobe br_netfilter

# Set system configurations for Kubernetes networking:
cat <<EOF | sudo tee /etc/sysctl.d/99-kubernetes-cri.conf
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
net.bridge.bridge-nf-call-ip6tables = 1
EOF

# Apply new settings:
sudo sysctl --system

# Install containerd:
sudo apt-get update && sudo apt-get install -y containerd

# Create default configuration file for containerd:
sudo mkdir -p /etc/containerd

# Generate default containerd configuration and save to the newly created default file:
sudo containerd config default | sudo tee /etc/containerd/config.toml

# Restart containerd to ensure new configuration file usage:
sudo systemctl restart containerd

# Disable swap:
sudo swapoff -a

# Disable swap on startup in /etc/fstab:
sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab

# Install dependency packages:
sudo apt-get update && sudo apt-get install -y apt-transport-https curl

# Download and add GPG key:
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -

# Add Kubernetes to repository list:
cat <<EOF | sudo tee /etc/apt/sources.list.d/kubernetes.list
deb https://apt.kubernetes.io/ kubernetes-xenial main
EOF

# Update package listings:
sudo apt-get update

# Install Kubernetes packages of choice (Note: If you get a dpkg lock message, just wait a minute or two before trying the command again):
# Updtae 1.26.0-00 based on Kubernetes release version
sudo apt-get install -y kubelet=1.26.0-00 kubeadm=1.26.0-00 kubectl=1.26.0-00

# Turn off automatic updates:
sudo apt-mark hold kubelet kubeadm kubectl


