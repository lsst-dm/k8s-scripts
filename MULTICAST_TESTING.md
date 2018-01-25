# k8s-scripts
# Multicast testing

This is a simple test of whether or not containers on different systems can communicate with each other over multicast.

Deploy a few tcontainers, each containing development tools so that C programs can be compiled.  Be sure to pick
two of containers which are running on different nodes.  You can check which nodes a pod is running on by adding
the "-o wide" option to the pod display command.

$ kubectl get pods -o wide
NAME                     READY     STATUS    RESTARTS   AGE       IP          NODE
stack-67dbd45764-2fbnb   1/1	   Running   0          2h        10.32.0.4   srp-node1.univ.edu
stack-67dbd45764-b4nv5   1/1	   Running   0          2h        10.40.0.3   srp-node2.univ.edu
stack-67dbd45764-k84wf   1/1	   Running   0          2h        10.32.0.3   srp-node1.univ.edu
stack-67dbd45764-nbmhf   1/1	   Running   0          2h        10.40.0.4   srp-node2.univ.edu
stack-67dbd45764-nnjww   1/1	   Running   0          2h        10.40.0.2   srp-node2.univ.edu
stack-67dbd45764-wljpg   1/1	   Running   0          2h        10.32.0.2   srp-node1.univ.edu
$

Execute a shell on each container you're testing.  For example, for container "stack-67dbd45764-2fbnb"
you would execute:

$ kubectl exec -it stack-67dbd45764-2fbnb /bin/sh

This runs a shell in that container, which is running on srp-node1.univ.edu


After executing shells on all containers you're testing against,  run the following:


Clone the following github repo:

$ git clone https://github.com/troglobit/mtools
Cloning into 'mtools'...
remote: Counting objects: 103, done.        
remote: Compressing objects: 100% (48/48), done.        
remote: Total 103 (delta 53), reused 103 (delta 53), pack-reused 0        
Receiving objects: 100% (103/103), 46.71 KiB | 0 bytes/s, done.
Resolving deltas: 100% (53/53), done.
$ cd mtools
$ make


On one system, type:

$ ./msend

Now sending to multicast group: 224.1.1.1
Sending msg 1, TTL 1, to 224.1.1.1:4444: 
Sending msg 2, TTL 1, to 224.1.1.1:4444: 
Sending msg 3, TTL 1, to 224.1.1.1:4444: 

On the other system, type:

$ ./mreceive

Receive msg 1 from 10.47.0.2:4444: 
Receive msg 2 from 10.47.0.2:4444: 
Receive msg 3 from 10.47.0.2:4444: 


Since this is multicast traffic, you can run
multiple receive commands on different containers
and all those packets should be received.  Note
that since this isn't running a reliable multicast
protocol, some packets may be dropped.
