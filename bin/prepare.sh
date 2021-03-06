#!/bin/bash
if [ "$1" = "" ]; then
	echo "usage: $0 version"
	exit 10
fi
version=$1


#
# initial lifting for installing latest kubernetes - refer to README.md for additional steps required after this first part of the install is completed
#

#
# system software update
#
yum update -y


#
# Install docker
#
yum install -y docker
systemctl enable docker && systemctl start docker

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
# Turn off enforcement
#
setenforce 0

#
# Install kubernetes utils.
#
yum install -y kubelet-$version kubeadm-$version kubectl-$version


# add swap flag, since we're running on a system with swap enabled....


#
# add option to turn off swap warning (works for Kubernetes versions < 1.9)
#
KUBEADM_CONF=/etc/systemd/system/kubelet.service.d/10-kubeadm.conf
printf '%s\n' 2i 'Environment="KUBELET_EXTRA_ARGS=--fail-swap-on=false"' . x | ex $KUBEADM_CONF

#
# enable and start kubelet
#
systemctl enable kubelet && systemctl start kubelet

#
# set iptables
#
cat <<EOF >  /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF
sysctl -p /etc/sysctl.d/k8s.conf

sysctl net.ipv4.ip_forward=1
