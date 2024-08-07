#!/usr/env/bin bash


echo "---[Pre-requisites]---"
# (curl --fail -s https://git.va.th.ten >/dev/null && echo " [X] : vpn-access") || (echo " [ ] : vpn-access\n     ERROR: Can't reach TEN, make sure you're on the VPN" && exit 1)

echo "---[Required Tools]---"
# Install MiniKube
if [ -x "$(command -v minikube)" ]; then
    echo ' [x] : minikube'
else
    echo " ERROR : Install minikube"
    echo "   - Run 'make install' first"
    exit 1
fi
# Install Homebrew
if [ -x "$(command -v brew)" ]; then
    echo ' [x] : homebrew'
else
    echo " ERROR : Install homebrew"
    echo "   - Run 'make install' first"
    exit 1
fi
# Install Docker
if [ -x "$(command -v docker)" ]; then
    echo ' [x] : docker'
else
    echo " ERROR : Install docker"
    echo "   - Run 'make install' first"
    exit 1
fi
echo "----------------------"
