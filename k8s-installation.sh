#!/bin/bash

# update apt
echo == update
echo ======================================
echo ======================================
sleep 2
sudo apt update -y

# dist-upgrade
echo == dist-upgrade
echo ======================================
echo ======================================
sleep 2
sudo apt dist-upgrade -y

# install docker
echo == install Docker engine
echo ======================================
echo ======================================
sleep 2
# install docker
wget -qO- get.docker.com | sh
# check the installed docker
sudo docker info

# disable swap
# running with swap on is not supported in k8s
echo == disable swap
echo ======================================
echo ======================================
sleep 2
sudo dphys-swapfile swapoff && \
sudo dphys-swapfile uninstall && \
sudo update-rc.d dphys-swapfile remove

# add k8s repository
echo == add kubernetes repostiory
echo ======================================
echo ======================================
sleep 2
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add - && \
echo "deb http://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list

# install k8s
echo == install k8s
echo ======================================
echo ======================================
sleep 2
apt install -y kubelet kubeadm kubectl kubernetes-cni
  
# echo Adding " cgroup_enable=cpuset cgroup_memory=1 cgroup_enable=memory" to /boot/cmdline.txt

# sudo cp /boot/cmdline.txt /boot/cmdline_backup.txt
# orig="$(head -n1 /boot/cmdline.txt) cgroup_enable=cpuset cgroup_memory=1 cgroup_enable=memory"
# echo $orig | sudo tee /boot/cmdline.txt

# echo Please reboot
