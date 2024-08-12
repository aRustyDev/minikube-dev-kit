#!/usr/bin/env bash

TARGET=$1

minikube_config(){
	minikube ssh -- curl -Lo /tmp/kernel-headers-linux-4.19.94.tar.lz4 https://storage.googleapis.com/minikube-kernel-headers/kernel-headers-linux-4.19.94.tar.lz4
	minikube ssh -- sudo mkdir -p /lib/modules/4.19.94/build
	minikube ssh -- sudo tar -I lz4 -C /lib/modules/4.19.94/build -xvf /tmp/kernel-headers-linux-4.19.94.tar.lz4
	minikube ssh -- rm /tmp/kernel-headers-linux-4.19.94.tar.lz4
}

minikube config set driver $(yq '.driver' "config/$TARGET.yaml")
minikube config set cpus $(yq '.resources.cpu' "config/$TARGET.yaml")
minikube config set memory $(yq '.resources.ram' "config/$TARGET.yaml")
minikube config set disk-size $(yq '.resources.disk' "config/$TARGET.yaml")
minikube config set WantUpdateNotification false
minikube config set kubernetes-version $(if ! [ $(yq '.kubev' "config/$TARGET.yaml") == "" ]; then echo $(yq '.kubev' "config/$TARGET.yaml") else; echo "v1.28.3" fi)
minikube config set log_dir $(if ! [ $(yq '.log_dir' "config/$TARGET.yaml") == "" ]; then echo $(yq '.log_dir' "config/$TARGET.yaml") else; echo "./logs/" fi)
minikube config set insecure-registry "0.0.0.0/0"

minikube start $(if ! [ $(yq '.cilium' "config/$TARGET.yaml") == "enabled" ]; then echo "--cni=cilium"; fi)
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
