#!/usr/env/bin bash

kill $(ps ax | grep "kubectl port-forward" | grep -v "grep" | cut -d ' ' -f1) || true
# kubectl delete pvc -n datapipe data-postgresql-0
minikube stop
minikube delete --all --purge
