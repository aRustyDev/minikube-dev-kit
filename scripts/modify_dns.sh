#!/usr/bin/env bash

if [ $1 == "down" ]; then
    echo "Removing DNS configuration"
    mv /etc/hosts.bak /etc/hosts 2> /dev/null
    rm /etc/resolver/minikube 2> /dev/null
    launchctl disable system/com.apple.mDNSResponder.reloaded
    launchctl enable system/com.apple.mDNSResponder.reloaded
    exit 0
fi
if [ $1 == "up" ]; then
    # echo "Configuring DNS to Minikube"
    # openssl x509 -inform der -in my_company.cer -out my_company.pem
    # mkdir -p $HOME/.minikube/certs
    # cp my_company.pem $HOME/.minikube/certs/my_company.pem

    echo "Configuring DNS to Minikube"
    cp /etc/hosts /etc/hosts.bak
    cat <<EOF >> /etc/hosts
$(minikube ip)    pi3.mk
$(minikube ip)    memphis.pi3.mk
$(minikube ip)    metabase.pi3.mk
$(minikube ip)    spark.pi3.mk
$(minikube ip)    metadata.pi3.mk
EOF
    mkdir -p /etc/resolver
    cp dns/resolvr.conf /etc/resolver/minikube
    export MKIP=$(minikube ip)
    sed -i -r "s/MINIKUBE_IP/$MKIP/" "/etc/resolver/minikube"
    launchctl disable system/com.apple.mDNSResponder.reloaded
    launchctl enable system/com.apple.mDNSResponder.reloaded
    exit 0
fi
# kubectl port-forward svc/spark-master-svc 9001:80 --namespace spark  > /dev/null&
# kubectl port-forward svc/memphis 6666:6666 9000:9000 7770:7770 --namespace memphis > /dev/null &
# kubectl port-forward svc/memphis-rest-gateway 4444:4444 --namespace memphis > /dev/null &
# kubectl port-forward service/memphis-rest-gateway 9002:5432 --namespace memphis > /dev/null &
