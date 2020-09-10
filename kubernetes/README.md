![RPi-version](https://img.shields.io/badge/rpi-v4-informational) ![date-passing](https://img.shields.io/badge/sep--10--2020-passing-success) 

# Kubernetes step-by-step installation on Raspberry Pi 4

## 1. Environment setup
### 1.1. Update Raspberry Pi
```
rpi-update
```

### 1.2. Setup cgroups
Adding "cgroup_enable=cpuset cgroup_memory=1 cgroup_enable=memory" to /boot/cmdline.txt
```
sudo cp /boot/cmdline.txt /boot/cmdline_backup.txt
orig="$(head -n1 /boot/cmdline.txt) cgroup_enable=cpuset cgroup_memory=1 cgroup_enable=memory"
echo $orig | sudo tee /boot/cmdline.txt
```

### 1.3. Allow iptables to see bridged traffic
Please refer to in-detail description [here](https://kubernetes.io/docs/concepts/extend-kubernetes/compute-storage-net/network-plugins/#network-plugin-requirements)
```
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF
```
```
sudo sysctl --system
```

### 1.4. Disable swap
Running with swap on is not supported in k8s
```
sudo dphys-swapfile swapoff && \
sudo dphys-swapfile uninstall && \
sudo systemctl disable dphys-swapfile
```

### 1.5. Add k8s repository
```
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add - && \
echo "deb http://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list
```

### 1.6. Update apt package list
```
sudo apt update -y
```

### 1.7. Upgrade apt package considering dependencies
```
sudo apt dist-upgrade -y
```

----

## 2. Reboot

---

## 3. Tools setup
### 3.1. Setup Docker
#### 3.1.1. Install Docker
```
wget -qO- get.docker.com | sh
```

#### 3.1.2. Check Docker installed
```
sudo docker info
```

#### 3.1.3. Modify a user account
```
sudo usermod pi -aG docker && newgrp docker
```
`-a, --append`
Add the user to the supplementary group(s). Use only with the -G option.

`-G, --groups GROUP1[,GROUP2,...[,GROUPN]]]`
A list of supplementary groups which the user is also a member of. Each group is separated from the next by a comma, with no intervening whitespace. The groups are subject to the same restrictions as the group given with the -g option.
If the user is currently a member of a group which is not listed, the user will be removed from the group. This behaviour can be changed via the -a option, which appends the user to the current supplementary group list.

Please refer to [here](https://linux.die.net/man/8/usermod)


#### 3.1.4. Change the default cgoups drive Docker uses
> Change the default cgroups driver Docker uses from cgroups to systemd to allow systemd to act as the cgroups manager and ensure there is only one cgroup manager in use.
```
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
```
sudo mkdir -p /etc/systemd/system/docker.service.d
```
Reload daemon
```
sudo systemctl daemon-reload
```
Restart docker
```
sudo systemctl restart docker
```


### 3.2. Setup Kubernetes
#### 3.2.1. Install Kubernetes on both Masters & Workers
```
apt install -y kubelet kubeadm kubectl kubernetes-cni
```

#### 3.2.2. Initialize k8s cluster on a Master
```
kubeadm init --apiserver-advertise-address [YOUR_MASTER_IP_ADDRESS] --pod-network-cidr=[YOUR_POD_NETWORK_CIDR]
```
CIDR: Classless Inter-Domain Routing

e.g., YOUR_MASTER_IP_ADDRESS: 192.168.10.100, YOUR_POD_NETWORK_CIDR: 192.168.0.0/16

#### 3.2.3. Allow a regular user to control the cluster
From the result of `kubeadm init`, you can see the below commands.

***See the result of `kubeadm init`***
```
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
```

#### 3.2.3. Join Workers to the master
From the result of `kubeadm init`, you can see the below commands.

***Excute this on Workers***
```
kubeadm join [YOUR_MASTER_IP_ADDRESS]:6443 --token xxxxxxxxxxxxxxxxxxxxxxx \
    --discovery-token-ca-cert-hash sha256:xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
```

#### 3.2.4. Install conatiner network plugins
There are some plugins. You can select what you want.

***I have succeeded in installing the flannel on Raspberry Pi 4 on Sep. 10th, 2020.
Calico latest container image doesn't seem to support arm system architecture. I didn't try to install weaveNet.***

```
kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml
```

## 4. Intallation checking
### 4.1. Get pods
```
kubectl get pods --namespace kube-system
```

### 4.2. Get nodes
```
kubectl get nodes
```

## 5. Remove Kubernetes cluster
Some files could be removed mannually.
```
kubeadm reset
```
