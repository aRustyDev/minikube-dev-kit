#!/usr/env/bin bash

kubectl create deployment web --image=gcr.io/google-samples/hello-app:1.0
kubectl expose deployment web --type=NodePort --port=8080
# minikube service web --url
kubectl port-forward service/memphis 6666:6666 9000:9000 7770:7770 --namespace datapipe > /dev/null &
kubectl port-forward service/memphis-rest-gateway 4444:4444 --namespace datapipe > /dev/null &
kubectl port-forward service/postgresql 5432:5432 --namespace datapipe > /dev/null &
export POD_NAME=$(kubectl get pods --namespace datapipe -l "app=metabase,release=metabase" -o jsonpath="{.items[0].metadata.name}")
kubectl port-forward --namespace datapipe $POD_NAME 8080:3000 > /dev/null &
kubectl port-forward service/openmetadata 8585:http > /dev/null &
