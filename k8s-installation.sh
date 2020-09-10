#!/bin/bash

# update apt package list
echo == update apt package list
echo ======================================
echo ======================================
sleep 2
sudo apt update -y

# upgrade apt package considering dependencies
echo == upgrade apt package considering dependencies
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

# install docker
echo == install Docker engine
echo ======================================
echo ======================================
sleep 2
# change the default cgroups driver Docker uses from cgroups to systemd 
# to allow systemd to act as the cgroups manager and 
# ensure there is only one cgroup manager in use.
sudo cat > /etc/docker/daemon.json <<EOF
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2"
}
EOF

sudo mkdir -p /etc/systemd/system/docker.service.d
sudo systemctl daemon-reload
sudo systemctl restart docker

# disable swap
# running with swap on is not supported in k8s
echo == disable swap
echo ======================================
echo ======================================
sleep 2
sudo swapoff -a

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

# set up cgroups
echo == "set up cgroups"
echo ======================================
echo ======================================
sleep 2
echo Adding " cgroup_enable=cpuset cgroup_memory=1 cgroup_enable=memory" to /boot/cmdline.txt
sudo cp /boot/cmdline.txt /boot/cmdline_backup.txt
orig="$(head -n1 /boot/cmdline.txt) cgroup_enable=cpuset cgroup_memory=1 cgroup_enable=memory"
echo $orig | sudo tee /boot/cmdline.txt

echo Please reboot
