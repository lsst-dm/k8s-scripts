# k8s-scripts
# Install of Kubernetes with Flannel on OpenStack

The following installs Kubernetes 1.8.5

Files are available in the http://www.github.com/lsst-dm/k8s-scripts.git

Including:

    1.  bin/prepare_185.sh - install script for first part of the install


## On all nodes of the clusters, execute the following:

1) Clone the repository at github.com/lsst-dm/k8s-scripts.git
2) Enter the k8s-scripts directory
3) As root, execute the command:

`# bin/prepare_vm.sh`

This will execute a series of commands to update the operating system, and to install docker and the Kubernetes software.  This will take a few minutes to install.

## On the Head node

Execute the following:

`# kubeadm init`

This will give output similar to this:

```
[kubeadm] WARNING: kubeadm is in beta, please do not use it for production clusters.
[init] Using Kubernetes version: v1.8.7
[init] Using Authorization modes: [Node RBAC]
[preflight] Running pre-flight checks
[preflight] WARNING: docker version is greater than the most recently validated version. Docker version: 17.09.0-ce. Max validated version: 17.03
[kubeadm] WARNING: starting in 1.8, tokens expire after 24 hours by default (if you require a non-expiring token use --token-ttl 0)
[certificates] Generated ca certificate and key.
[certificates] Generated apiserver certificate and key.
[certificates] apiserver serving cert is signed for DNS names [me-manager.os.univ.edu kubernetes kubernetes.default kubernetes.default.svc kubernetes.default.svc.cluster.local] and IPs [10.96.0.1 172.16.1.102]
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
[markmaster] Will mark node me-manager.os.univ.edu as master by adding a label and a taint
[markmaster] Master me-manager.os.univ.edu tainted and labelled with key/value: node-role.kubernetes.io/master=""
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
```


Please note that the line "[init] Using Kubernetes version: 1.8.7" (this number may vary).   The "version: 1.8.7" refers to the control plane binaries for Kubernetes 
which, by default, will always install the "stable" vesion of the 1.x release you're using.  In this case, the client binaries are running 1.8.5, but the control plan binaries
run as 1.8.7.

Also take note of the final output of “kubeadm init”, and execute the following as a non-root user:

```
$ mkdir -p $HOME/.kube
$ sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
$ sudo chown $(id -u):$(id -g) $HOME/.kube/config
```

## Start the Weave overlay

$ kubectl apply -f https://cloud.weave.works/k8s/v1.7/net




## On all worker nodes

Execute the “kubeadm join” line listed as the last part of the “kubeadm init” command that ran on the head node.  In the example above, run the following on each worker node:

`kubeadm join --token 59f95a.3c3f1d22a35f24df 172.16.1.102:6443 --discovery-token-ca-cert-hash sha256:9a3893600d1206d3a51b6988fd31bab1d79523c8cb1b50973cec6ae1397c44e9`

You may get an error about something failing preflight checks, most likely "Swap".  This means you're trying to execute on a machine with Swap enabled, which is not recommended.
If you do see this issue and wish to continue with the system's Swap enabled", add the option "--skip-preflight-checks" to the end of the command above.


## From the head node,

Check the cluster node status, and wait for all nodes to be in the “Ready” state.

`$ kubectl get nodes`


Check to see all system level pods are running.  These run in the "kube-system" namespace

`$ kubectl get pods --namespace kube-system`

You should see something like:

```
$ kubectl get pods --namespace kube-system
NAME                                              READY     STATUS    RESTARTS   AGE
etcd-me-manager.os.univ.edu                      1/1       Running   0          1h
kube-apiserver-me-manager.os.univ.edu            1/1       Running   0          1h
kube-controller-manager-me-manager.os.univ.edu   1/1       Running   0          1h
kube-dns-545bc4bfd4-s8w8n                        3/3       Running   0          1h
kube-flannel-ds-7dwkv                            1/1       Running   0          52m
kube-flannel-ds-khbxb                            1/1       Running   0          18m
kube-flannel-ds-sv59n                            1/1       Running   1          46m
kube-proxy-f59mq                                 1/1       Running   0          18m
kube-proxy-fhldr                                 1/1       Running   0          1h
kube-proxy-g8g2p                                 1/1       Running   0          46m
kube-scheduler-me-manager.os.univ.edu            1/1       Running   0          1h
```
