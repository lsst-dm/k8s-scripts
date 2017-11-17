# k8s-scripts
# Local docker registry deployment

## Install httpd-tools to get htpasswd

`$ yum install -y httpd-tools`

## Create htpasswd

`$ htpasswd -c htpasswd centos`

Login to local registry

`$ kubectl --namespace=kube-system create secret generic registry-auth-secret --from-file=htpasswd=htpasswd`

## On head node:

`$ kubectl create -f yml/registry.yml`

`$ POD=$(kubectl get pods --namespace kube-system -l k8s-app=kube-registry-upstream -o template --template '{{range .items}}{{.metadata.name}} {{.status.phase}}{{"\n"}}{{end}}' | grep Running | head -1 | cut -f1 -d' ')`

`$ nohup kubectl port-forward --namespace kube-system $POD 5000:5000 &`


## For each node in the cluster, from the head node: 
`$ scp /etc/kubernetes/admin.conf node-name-goes-here:.kube/config`

## On each worker node:

`$ kubectl create -f yml/node-redirect.yml`

`$ POD=$(kubectl get pods --namespace kube-system -l k8s-app=kube-registry-upstream -o template --template '{{range .items}}{{.metadata.name}} {{.status.phase}}{{"\n"}}{{end}}' | grep Running | head -1 | cut -f1 -d' ')`

`$ nohup kubectl port-forward --namespace kube-system $POD 5000:5000 &`

To test:

### Pull down an image from dockerhub
`$ docker pull srp3/stack:v5`

### Tag it
`$ docker tag srp3/stack:v5 localhost:5000/stack6`

### Push the tagged version to the local registry
`$ docker push localhost:5000/stack6`

### Remove the tagged version
`$ docker rmi localhost:5000/stack6`

### Remove the image pulled from dockerhub
`$ docker rmi srp3/stack:v5`

Pod should now be available through local docker registry.

Pods should now be able to be deployed, referencing the local registry.

Try running the following command using the file in the yml directory:

`$ kubectl create -f registrytest.yml`

`$ kubectl exec -it mystack6 /bin/bash`

and you should log into that container.
