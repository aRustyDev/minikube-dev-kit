#!/usr/env/bin bash

# kubectl delete pvc -n datapipe data-postgresql-0
minikube stop
minikube delete --all --purge
