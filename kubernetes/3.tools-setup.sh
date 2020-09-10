#!/bin/bash

# install docker
echo 
echo =================================================
echo == install Docker engine
echo =================================================
sleep 2
# install docker
wget -qO- get.docker.com | sh
# check the installed docker
sudo docker info

# change the default cgoups drive Docker uses
echo 
echo =================================================
echo == change the default cgoups drive Docker uses
echo =================================================
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
# make a directory
sudo mkdir -p /etc/systemd/system/docker.service.d
# reload daemon
sudo systemctl daemon-reload
# restart docker
sudo systemctl restart docker

# install k8s
echo 
echo =================================================
echo == install k8s
echo =================================================
sleep 2
apt install -y kubelet kubeadm kubectl kubernetes-cni
