# k8s-scripts
Initial install of Kubernetes with Flannel

The following installs Kubernetes 1.8.3

Files are available in the http://www.github.com/lsst-dm/k8s-scripts.git

Including:

    1.  bin/prepare.sh - install script for first part of the install
    2.  etc/newhosts.txt - will be appended to /etc/hosts on each system
    3.  yml/registry.yml - used to create local docker registry on master
    4.  yml/node-redirect.yml - used on nodes to for the registry 



ON THE HEAD NODE

Clone the repository at github.com/lsst-dm/k8s-scripts.git
Enter the k8s-scripts directory
Edit the etc/newhosts.txt file and add all hosts on which you’ll be installing Kubernetes 
(including the head node).  This file will be appended to /etc/hosts during the installation 
process.

Copy the k8s-scripts directory to all the rest of the nodes onto which you’ll be installing Kubernetes.

ON ALL MACHINES IN THE CLUSTER

Execute the command:

bin/prepare.sh 

This will execute a series of commands to append the hosts to the /etc/hosts file, update the operating system, and to install docker and the Kubernetes software.  This will take a few minutes to install.

AFTER PREPARE.SH IS FINISHED -

On the Head node, execute the following:


sh-4.2# kubeadm init --pod-network-cidr=10.244.0.0/16

This will give output similar to this:


[kubeadm] WARNING: kubeadm is in beta, please do not use it for production clusters.
[init] Using Kubernetes version: v1.8.3
[init] Using Authorization modes: [Node RBAC]
[preflight] Running pre-flight checks
[preflight] WARNING: docker version is greater than the most recently validated version. Docker version: 17.09.0-ce. Max validated version: 17.03
[kubeadm] WARNING: starting in 1.8, tokens expire after 24 hours by default (if you require a non-expiring token use --token-ttl 0)
[certificates] Generated ca certificate and key.
[certificates] Generated apiserver certificate and key.
[certificates] apiserver serving cert is signed for DNS names [srp-manager.os.ncsa.edu kubernetes kubernetes.default kubernetes.default.svc kubernetes.default.svc.cluster.local] and IPs [10.96.0.1 172.16.1.102]
[certificates] Generated apiserver-kubelet-client certificate and key.
[certificates] Generated sa key and public key.
[certificates] Generated front-proxy-ca certificate and key.
[certificates] Generated front-proxy-client certificate and key.
[certificates] Valid certificates and keys now exist in "/etc/kubernetes/pki"
[kubeconfig] Wrote KubeConfig file to disk: "admin.conf"
[kubeconfig] Wrote KubeConfig file to disk: "kubelet.conf"
[kubeconfig] Wrote KubeConfig file to disk: "controller-manager.conf"
[kubeconfig] Wrote KubeConfig file to disk: "scheduler.conf"
[controlplane] Wrote Static Pod manifest for component kube-apiserver to "/etc/kubernetes/manifests/kube-apiserver.yaml"
[controlplane] Wrote Static Pod manifest for component kube-controller-manager to "/etc/kubernetes/manifests/kube-controller-manager.yaml"
[controlplane] Wrote Static Pod manifest for component kube-scheduler to "/etc/kubernetes/manifests/kube-scheduler.yaml"
[etcd] Wrote Static Pod manifest for a local etcd instance to "/etc/kubernetes/manifests/etcd.yaml"
[init] Waiting for the kubelet to boot up the control plane as Static Pods from directory "/etc/kubernetes/manifests"
[init] This often takes around a minute; or longer if the control plane images have to be pulled.
[apiclient] All control plane components are healthy after 27.501157 seconds
[uploadconfig] Storing the configuration used in ConfigMap "kubeadm-config" in the "kube-system" Namespace
[markmaster] Will mark node srp-manager.os.ncsa.edu as master by adding a label and a taint
[markmaster] Master srp-manager.os.ncsa.edu tainted and labelled with key/value: node-role.kubernetes.io/master=""
[bootstraptoken] Using token: 59f95a.3c3f1d22a35f24df
[bootstraptoken] Configured RBAC rules to allow Node Bootstrap tokens to post CSRs in order for nodes to get long term certificate credentials
[bootstraptoken] Configured RBAC rules to allow the csrapprover controller automatically approve CSRs from a Node Bootstrap Token
[bootstraptoken] Configured RBAC rules to allow certificate rotation for all node client certificates in the cluster
[bootstraptoken] Creating the "cluster-info" ConfigMap in the "kube-public" namespace
[addons] Applied essential addon: kube-dns
[addons] Applied essential addon: kube-proxy

Your Kubernetes master has initialized successfully!

To start using your cluster, you need to run (as a regular user):

  mkdir -p $HOME/.kube
  sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
  sudo chown $(id -u):$(id -g) $HOME/.kube/config

You should now deploy a pod network to the cluster.
Run "kubectl apply -f [podnetwork].yaml" with one of the options listed at:
  http://kubernetes.io/docs/admin/addons/

You can now join any number of machines by running the following on each node
as root:

  kubeadm join --token 59f95a.3c3f1d22a35f24df 172.16.1.102:6443 --discovery-token-ca-cert-hash sha256:9a3893600d1206d3a51b6988fd31bab1d79523c8cb1b50973cec6ae1397c44e9 



Take note of the final output of “kubeadm init”, and execute the following as a non-root user:

  mkdir -p $HOME/.kube
  sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
  sudo chown $(id -u):$(id -g) $HOME/.kube/config


ON ALL WORKER NODES, execute the “kubeadm join” line listed as the last part of the “kubeadm init” command that ran on the head node.  In the example above, run the following on each worker node:

kubeadm join --token 59f95a.3c3f1d22a35f24df 172.16.1.102:6443 --discovery-token-ca-cert-hash sha256:9a3893600d1206d3a51b6988fd31bab1d79523c8cb1b50973cec6ae1397c44e9


From the head node, 
Check the cluster node status by running:

$ kubectl get nodes

This should list all nodes you’ve installed the software on.


Apply the Flannel network layer:

$ kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml

Check the cluster node status, and wait for all nodes to be in the “Ready” state.

$ kubectl get nodes


Check to see all pods are running

$  kubectl get pods --namespace kube-system

You should see something like:

$ kubectl get pods --namespace kube-system
NAME                                              READY     STATUS    RESTARTS   AGE
etcd-srp-manager.os.ncsa.edu                      1/1       Running   0          1h
kube-apiserver-srp-manager.os.ncsa.edu            1/1       Running   0          1h
kube-controller-manager-srp-manager.os.ncsa.edu   1/1       Running   0          1h
kube-dns-545bc4bfd4-s8w8n                         3/3       Running   0          1h
kube-flannel-ds-7dwkv                             1/1       Running   0          52m
kube-flannel-ds-khbxb                             1/1       Running   0          18m
kube-flannel-ds-sv59n                             1/1       Running   1          46m
kube-proxy-f59mq                                  1/1       Running   0          18m
kube-proxy-fhldr                                  1/1       Running   0          1h
kube-proxy-g8g2p                                  1/1       Running   0          46m
kube-scheduler-srp-manager.os.ncsa.edu            1/1       Running   0          1h
