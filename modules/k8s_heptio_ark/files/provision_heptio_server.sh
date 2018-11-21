#!/bin/bash
#First the origin cluster
kubectl apply -f 00-prereqs.yaml --kubeconfig $KUBECONFIG_ORIG
kubectl apply -f 00-ark-config.yaml --kubeconfig $KUBECONFIG_ORIG
kubectl apply -f 10-deployment.yaml --kubeconfig $KUBECONFIG_ORIG
kubectl apply -f 20-schedule.yaml --kubeconfig $KUBECONFIG_ORIG

#Then the destination cluster
kubectl apply -f 00-prereqs.yaml --kubeconfig $KUBECONFIG_DEST
kubectl apply -f 00-ark-config-dest.yaml --kubeconfig $KUBECONFIG_DEST
kubectl apply -f 10-deployment.yaml --kubeconfig $KUBECONFIG_DEST

