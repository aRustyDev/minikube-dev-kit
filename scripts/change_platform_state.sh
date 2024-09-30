#!/usr/bin/env bash

change_state() {
    case $2 in
    "down")
        echo "Removing $1"
        case $1 in
            "docker")
                docker_down
                ;;
            "minikube")
                minikube_down
                ;;
            "orbstack")
                orbstack_down
                ;;
            "vault")
                vault_down
                ;;
            *)
                echo "Usage: <docker|minikube|orbstack|vault> <up|down>"
                exit 1
                ;;
        esac
        ;;
    "up")
        case $1 in
            "docker")
                docker_up
                ;;
            "minikube")
                minikube_up
                ;;
            "orbstack")
                orbstack_up
                ;;
            "vault")
                vault_up
                ;;
            *)
                echo "Usage: <docker|minikube|orbstack|vault> <up|down>"
                exit 1
                ;;
        esac
        ;;
    *)
        echo "Usage: <docker|minikube|orbstack|vault> <up|down>"
        exit 1
        ;;
    esac
}

# ==============================================================================
# DOCKER
# ==============================================================================

docker_down() {
    # Check if Docker is running
    docker info > /dev/null 2>&1
    if [ $? -eq 0 ]; then
        docker rm -f registry && \
        osascript -e 'quit app "Docker"'
    fi
    exit 0
}

docker_up() {
    echo "Configuring Docker Registry"
    open -a Docker && \
    sleep 10
    docker run -d -p 5000:5000 --restart always --name registry registry:2
    exit 0
}

# ==============================================================================
# MINIKUBE
# ==============================================================================

minikube_down() {
    minikube delete --all --purge
    exit 0
}

minikube_up() {
    minikube config set driver $(yq '.driver' "config/$TARGET.yaml")
    minikube config set cpus $(yq '.resources.cpu' "config/$TARGET.yaml")
    minikube config set memory $(yq '.resources.ram' "config/$TARGET.yaml")
    minikube config set disk-size $(yq '.resources.disk' "config/$TARGET.yaml")
    minikube config set WantUpdateNotification false
    minikube config set kubernetes-version $(if [ $(yq '.kubev' "config/$TARGET.yaml") == "" ]; then echo $(yq '.kubev' "config/$TARGET.yaml"); else echo "v1.28.3"; fi)
    minikube config set log_dir $(if ! [ $(yq '.log_dir' "config/$TARGET.yaml") == "" ]; then echo $(yq '.log_dir' "config/$TARGET.yaml"); else echo "./logs/"; fi)
    minikube config set insecure-registry "0.0.0.0/0"

    minikube start $(if ! [ $(yq '.cni' "config/$TARGET.yaml") != "cilium" ]; then echo "--cni=cilium"; fi)
    export MINIKUBEIP=$(minikube ip)
    minikube addons enable registry-creds
    minikube addons enable ingress
    minikube addons enable ingress-dns
    sleep 30
    exit 0
}

# ==============================================================================
# ORBSTACK
# ==============================================================================

orbstack_down() {
    orb stop k8s
    orb delete k8s
    exit 0
}

orbstack_up() {
    orb start k8s
    sleep 15
    exit 0
}

orbstack_cycle() {
    orb restart k8s
    exit 0
}

# ==============================================================================
# k3s # TODO: implement
# ==============================================================================

# ==============================================================================
# VAULT
# ==============================================================================

vault_down() {
    pkill -9 vault
    exit 0
}

vault_up() {
    bash $PWD/scripts/vault.sh
    exit 0
}

# ==============================================================================
# k3d # TODO: implement
# ==============================================================================


# ==============================================================================
# KIND (k8s in docker) # TODO: implement
# ==============================================================================

# ==============================================================================
# MAIN
# ==============================================================================

change_state $1 $2
