# k8s-scripts
# Install of Kubernetes with Flannel on OpenStack

The following installs the latesting version of Kubernetes, which at the time of this writing is version 1.9.2

Files are available in the http://www.github.com/lsst-dm/k8s-scripts.git

Including:

    1.  bin/prepare.sh - install script for first part of the install


## On all nodes of the clusters, execute the following:

1) Clone the repository at github.com/lsst-dm/k8s-scripts.git
2) Enter the k8s-scripts directory
3) As root, execute the command:

`# bin/prepare_vm.sh`

This will execute a series of commands to update the operating system, and to install docker and the Kubernetes software.  This will take a few minutes to install.

## On the Head node

Execute the following:

`# kubeadm init`

You may get an error when trying to execute this command on a node with Swap enabled.  If you don't wish to disable Swap on your system, but still which to continue
with the install, execute the following command:

`# kubeadm init --ignore-preflight-checks Swap`

This will give output similar to this:

```
# kubeadm init --ignore-preflight-errors Swap
[init] Using Kubernetes version: v1.9.2
[init] Using Authorization modes: [Node RBAC]
[preflight] Running pre-flight checks.
	[WARNING Swap]: running with swap on is not supported. Please disable swap
	[WARNING FileExisting-crictl]: crictl not found in system path
[certificates] Generated ca certificate and key.
[certificates] Generated apiserver certificate and key.
[certificates] apiserver serving cert is signed for DNS names [headnode.university.edu kubernetes kubernetes.default kubernetes.default.svc kubernetes.default.svc.cluster.local] and IPs [10.96.0.1 192.168.1.2]
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
[init] Waiting for the kubelet to boot up the control plane as Static Pods from directory "/etc/kubernetes/manifests".
[init] This might take a minute or longer if the control plane images have to be pulled.
[apiclient] All control plane components are healthy after 35.001060 seconds
[uploadconfig] Storing the configuration used in ConfigMap "kubeadm-config" in the "kube-system" Namespace
[markmaster] Will mark node headnode.university.edu as master by adding a label and a taint
[markmaster] Master headnode.university.edu tainted and labelled with key/value: node-role.kubernetes.io/master=""
[bootstraptoken] Using token: a24a11.0e6b932b0907deff
[bootstraptoken] Configured RBAC rules to allow Node Bootstrap tokens to post CSRs in order for nodes to get long term certificate credentials
[bootstraptoken] Configured RBAC rules to allow the csrapprover controller automatically approve CSRs from a Node Bootstrap Token
[bootstraptoken] Configured RBAC rules to allow certificate rotation for all node client certificates in the cluster
[bootstraptoken] Creating the "cluster-info" ConfigMap in the "kube-public" namespace
[addons] Applied essential addon: kube-dns
[addons] Applied essential addon: kube-proxy

Your Kubernetes master has initialized successfully!

To start using your cluster, you need to run the following as a regular user:

  mkdir -p $HOME/.kube
  sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
  sudo chown $(id -u):$(id -g) $HOME/.kube/config

You should now deploy a pod network to the cluster.
Run "kubectl apply -f [podnetwork].yaml" with one of the options listed at:
  https://kubernetes.io/docs/concepts/cluster-administration/addons/

You can now join any number of machines by running the following on each node
as root:

  kubeadm join --token a24a11.0e6b932b0907deff 192.168.1.2:6443 --discovery-token-ca-cert-hash sha256:1ca7fbf4d402849f34a6dbf5810ee584df015d6deeb55ca6ff1f0a87773b97f9
#
```

Please note that the line "[init] Using Kubernetes version: 1.9.2" (this number may vary).   The "version: 1.9.2" refers to the control plane binaries for Kubernetes 
which, by default, will always install the "stable" vesion of the 1.x release you're using.  In this case, the client binaries are running 1.9.2, and the control plan binaries
also run as 1.9.2.  If client libraries from 1.9.1 were installed, you'd get the same "1.9.2" message about the control plane binaries.  To change this default behavior,
Add "--kubernetes-version string", replace "string" with the version of the control backplane you wish to run.

Also take note of the final output of “kubeadm init”, and execute the following as a non-root user:

```
$ mkdir -p $HOME/.kube
$ sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
$ sudo chown $(id -u):$(id -g) $HOME/.kube/config
```

## Start the Weave overlay

Apply the Weave networking overlay

$ kubectl apply -f https://cloud.weave.works/k8s/v1.7/net
serviceaccount "weave-net" created
clusterrole "weave-net" created
clusterrolebinding "weave-net" created
role "weave-net" created
rolebinding "weave-net" created
daemonset "weave-net" created
$ 


There are a number of network overlays that could be used.  Weave was chosen because it supports multcast

## On all worker nodes

Execute the “kubeadm join” line listed as the last part of the “kubeadm init” command that ran on the head node.  In the example above, run the following on each worker node:

`kubeadm join --token a24a11.0e6b932b0907deff 192.168.1.2:6443 --discovery-token-ca-cert-hash sha256:1ca7fbf4d402849f34a6dbf5810ee584df015d6deeb55ca6ff1f0a87773b97f9`

You may get an error about something failing preflight checks, most likely "Swap".  This means you're trying to execute on a machine with Swap enabled, which is not recommended.
If you do see this issue and wish to continue with the system's Swap enabled", add the option "--ignore-preflight-checks" to the end of the command above.


## From the head node

Check the cluster node status, and wait for all nodes to be in the “Ready” state.

`$ kubectl get nodes`

You should see something like:

NAME                                  STATUS    ROLES     AGE       VERSION
headnode.university.edu               Ready     master    1d        v1.9.2
node1.university.edu                  Ready     <none>    1d        v1.9.2
node2.university.edu                  Ready     <none>    1d        v1.9.2

Check to see all system level pods are running.  These run in the "kube-system" namespace

`$ kubectl get pods --namespace kube-system`

You should see something like:

```
$ kubectl get pods --namespace kube-system
NAME                                               READY     STATUS    RESTARTS   AGE
etcd-me-manager.university.edu                    1/1       Running   0          1h
kube-apiserver-me-manager.university.edu          1/1       Running   0          1h
kube-controller-manager-me-manager.university.edu 1/1       Running   0          1h
kube-dns-545bc4bfd4-s8w8n                         3/3       Running   0          1h
kube-flannel-ds-7dwkv                             1/1       Running   0          52m
kube-flannel-ds-khbxb                             1/1       Running   0          18m
kube-flannel-ds-sv59n                             1/1       Running   1          46m
kube-proxy-f59mq                                  1/1       Running   0          18m
kube-proxy-fhldr                                  1/1       Running   0          1h
kube-proxy-g8g2p                                  1/1       Running   0          46m
kube-scheduler-me-manager.university.edu          1/1       Running   0          1h
```


You can now deploy your own pods to the cluster
