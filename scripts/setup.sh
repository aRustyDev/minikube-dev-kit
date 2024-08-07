#!/usr/bin/env bash

minikube_config(){
	minikube ssh -- curl -Lo /tmp/kernel-headers-linux-4.19.94.tar.lz4 https://storage.googleapis.com/minikube-kernel-headers/kernel-headers-linux-4.19.94.tar.lz4
	minikube ssh -- sudo mkdir -p /lib/modules/4.19.94/build
	minikube ssh -- sudo tar -I lz4 -C /lib/modules/4.19.94/build -xvf /tmp/kernel-headers-linux-4.19.94.tar.lz4
	minikube ssh -- rm /tmp/kernel-headers-linux-4.19.94.tar.lz4
}

minikube config set driver vmware
minikube config set cpus 4
minikube config set memory 8192
minikube config set disk-size 20480
minikube config set WantUpdateNotification false
minikube config set kubernetes-version v1.28.3
minikube config set insecure-registry "0.0.0.0/0"
# minikube config set EmbedCerts true
# minikube config set log_dir "/Users/$(whoami)/.minikube/logs"
# minikube config set container-runtime "docker"
minikube start --cni=cilium
export MINIKUBEIP=$(minikube ip)
minikube addons enable registry-creds
minikube addons enable ingress
minikube addons enable ingress-dns
sleep 30

# helm install cert-manager cert-manager/cert-manager --create-namespace --namespace cert-manager # -f ./helm/cert-manager.yaml
# helm install prometheus prometheus-community/prometheus --create-namespace --namespace metrics # -f ./helm/prometheus.yaml
# helm install jaeger jaegertracing/jaeger-operator --create-namespace --namespace metrics # -f ./helm/jaeger.yaml
# helm install external-secrets external-secrets/external-secrets --create-namespace --namespace=kube-system
# helm install cilium cilium/cilium --namespace=kube-system

# minikube_addons()
# cilium hubble enable
# cilium hubble port-forward
