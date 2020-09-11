![RPi-version](https://img.shields.io/badge/rpi-v4-informational) ![date-passing](https://img.shields.io/badge/sep--10--2020-passing-success) 

# Kubernetes step-by-step installation on Raspberry Pi 4
K8s or k8s: Kubernetes

## 1. Installation environment
### 1.1. Raspberry Pi 4 Model B Specifications
- Broadcom BCM2711, Quad core Cortex-A72 (ARM v8) 64-bit SoC @ 1.5GHz
- 4GB LPDDR4-3200 SDRAM (depending on model)
- Samsung Memory MB-MC512GAEU 512 GB Evo Plus
- See the rest of specifications [here](https://www.raspberrypi.org/products/raspberry-pi-4-model-b/specifications/)

### 1.2. Raspberry Pi OS
- Raspberry Pi OS (32-bit) Lite
- Version: August 2020
- Release date:2020-08-20
- Kernel version:5.4
- Size:435 MB

### 1.3. Network configuration
- master: 192.168.10.100
- worker1: 192.168.10.101
- worker2: 192.168.10.102

---

## 2. Prerequisites for setup K8s
### 2.1. Update Raspberry Pi
```bash
rpi-update
```

### 2.2. Setup cgroups
Adding "cgroup_enable=cpuset cgroup_memory=1 cgroup_enable=memory" to /boot/cmdline.txt
```bash
sudo cp /boot/cmdline.txt /boot/cmdline_backup.txt
orig="$(head -n1 /boot/cmdline.txt) cgroup_enable=cpuset cgroup_memory=1 cgroup_enable=memory"
echo $orig | sudo tee /boot/cmdline.txt
```

### 2.3. Allow iptables to see bridged traffic
Please refer to in-detail description [here](https://kubernetes.io/docs/concepts/extend-kubernetes/compute-storage-net/network-plugins/#network-plugin-requirements)
```bash
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF
```
```bash
sudo sysctl --system
```

### 2.4. Disable swap
Running with swap on is not supported in K8s
```bash
sudo dphys-swapfile swapoff && \
sudo dphys-swapfile uninstall && \
sudo systemctl disable dphys-swapfile
```

### 2.5. Add K8s repository
```bash
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add - && \
echo "deb http://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list
```

### 2.6. Update apt package list
```bash
sudo apt update -y
```

### 2.7. Upgrade apt package considering dependencies
```bash
sudo apt dist-upgrade -y
```

----

## 3. Reboot

---

## 4. Tools setup
### 4.1. Setup Docker
#### 4.1.1. Install Docker
```bash
wget -qO- get.docker.com | sh
```

#### 4.1.2. Check Docker installed
```bash
sudo docker info
```

#### 4.1.3. Modify a user account
```bash
sudo usermod pi -aG docker && newgrp docker
```
`-a, --append`
Add the user to the supplementary group(s). Use only with the -G option.

`-G, --groups GROUP1[,GROUP2,...[,GROUPN]]]`
A list of supplementary groups which the user is also a member of. Each group is separated from the next by a comma, with no intervening whitespace. The groups are subject to the same restrictions as the group given with the -g option.
If the user is currently a member of a group which is not listed, the user will be removed from the group. This behaviour can be changed via the -a option, which appends the user to the current supplementary group list.

Please refer to [here](https://linux.die.net/man/8/usermod)


#### 4.1.4. Change the default cgoups drive Docker uses
> Change the default cgroups driver Docker uses from cgroups to systemd to allow systemd to act as the cgroups manager and ensure there is only one cgroup manager in use.
```bash
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
```
Make a directory
```bash
sudo mkdir -p /etc/systemd/system/docker.service.d
```
Reload daemon
```bash
sudo systemctl daemon-reload
```
Restart docker
```bash
sudo systemctl restart docker
```


### 4.2. Setup Kubernetes
#### 4.2.1. Install Kubernetes on both Masters & Workers
```bash
apt install -y kubelet kubeadm kubectl kubernetes-cni
```

#### 4.2.2. Initialize k8s cluster on a Master
```bash
kubeadm init --apiserver-advertise-address [YOUR_MASTER_IP_ADDRESS] --pod-network-cidr=[YOUR_POD_NETWORK_CIDR]
```
CIDR: Classless Inter-Domain Routing

e.g., YOUR_MASTER_IP_ADDRESS: 192.168.10.100, YOUR_POD_NETWORK_CIDR: 192.168.0.0/16

#### 4.2.3. Allow a regular user to control the cluster
From the result of `kubeadm init`, you can see the below commands.

***See the result of `kubeadm init`***
```bash
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
```

#### 4.2.4. Join Workers to the master
From the result of `kubeadm init`, you can see the below commands.

***Excute this on Workers***
```bash
kubeadm join [YOUR_MASTER_IP_ADDRESS]:6443 --token xxxxxxxxxxxxxxxxxxxxxxx \
    --discovery-token-ca-cert-hash sha256:xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
```

#### 4.2.5. Install conatiner network plugins
There are some plugins. You can select what you want.

***I have succeeded in installing the flannel on Raspberry Pi 4 on Sep. 10th, 2020.
Calico latest container image doesn't seem to support arm system architecture. I didn't try to install weaveNet.***

```bash
kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml
```

## 5. Intallation checking
### 5.1. Get pods
```bash
kubectl get pods --namespace kube-system
```

### 5.2. Get nodes
```bash
kubectl get nodes
```

## 6. Remove Kubernetes cluster
Some files could be removed mannually.
```bash
kubeadm reset
```
