#!/bin/bash
source prepare.sh
kubeadm init --pod-network-cidr=10.244.0.0/16
