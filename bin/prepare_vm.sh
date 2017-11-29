#!/bin/bash

#
# initial lifting for installing kubernetes - refer to README.md for additional steps required after this first part of the install is completed
#

#
# system software update
#
yum update -y

#
# install kubernetes repo
#
cat << EOF >/etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg
        https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
EOF

#
# Add the Docker public key
#
rpm --import "https://sks-keyservers.net/pks/lookup?op=get&search=0xee6d536cf7dc86e2d7d56f59a178ac6c6238f52e"

#
# Install the Docker repo
#
yum-config-manager --add-repo https://packages.docker.com/1.12/yum/repo/main/centos/7

#
# Install docker
#
yum install -y docker

#
# Add centos as a user of docker
#
#usermod -aG docker centos

#
# Turn off enforcement
#
setenforce 0

#
# Install kubernetes utils.
#
yum install -y kubelet-1.8.3 kubeadm-1.8.3 kubectl-1.8.3

#
# enable and start docker
#
systemctl enable docker
systemctl start docker


#
# change systemd to cgroupfs
#
KUBEADM_CONF=/etc/systemd/system/kubelet.service.d/10-kubeadm.conf
echo "%s/KUBELET_CGROUP_ARGS=systemd/KUBELET_CGROUP_ARGS=cgroupfs/g
w
q
" | ex $KUBEADM_CONF

#
# add option to turn off swap warning.
#
printf '%s\n' 2i 'Environment="KUBELET_EXTRA_ARGS=--fail-swap-on=false"' . x | ex $KUBEADM_CONF

#
# enable and start kubelet - this will get errors on the master until the "kubeadm init" is executed (which is done after you run this script)
#
systemctl enable kubelet
systemctl start kubelet


#
# set iptables
#
echo '1' > /proc/sys/net/bridge/bridge-nf-call-iptables
