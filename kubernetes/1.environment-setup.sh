#!/bin/bash


# update Raspberry Pi
echo 
echo =================================================
echo == update Raspberry Pi
echo =================================================
sleep 2
sudo rpi-update

# set up cgroups
echo 
echo =================================================
echo == "set up cgroups"
echo =================================================
sleep 2
echo Adding " cgroup_enable=cpuset cgroup_memory=1 cgroup_enable=memory" to /boot/cmdline.txt
sudo cp /boot/cmdline.txt /boot/cmdline_backup.txt
orig="$(head -n1 /boot/cmdline.txt) cgroup_enable=cpuset cgroup_memory=1 cgroup_enable=memory"
echo $orig | sudo tee /boot/cmdline.txt

# allow iptables to see bridged traffic
echo 
echo =================================================
echo == allow iptables to see bridged tracce
echo =================================================
# https://kubernetes.io/docs/concepts/extend-kubernetes/compute-storage-net/network-plugins/#network-plugin-requirements
sleep 2
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF

sudo sysctl --system

# disable swap
# running with swap on is not supported in k8s
echo 
echo =================================================
echo == disable swap
echo =================================================
sleep 2
sudo dphys-swapfile swapoff && \
sudo dphys-swapfile uninstall && \
sudo systemctl disable dphys-swapfile

# add k8s repository
echo 
echo =================================================
echo == add kubernetes repostiory
echo =================================================
sleep 2
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add - && \
echo "deb http://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list

# update apt package list
echo 
echo =================================================
echo == update apt package list
echo =================================================
sleep 2
sudo apt update -y

# upgrade apt package considering dependencies
echo 
echo =================================================
echo == upgrade apt package considering dependencies
echo =================================================
sleep 2
sudo apt dist-upgrade -y

echo Please reboot
