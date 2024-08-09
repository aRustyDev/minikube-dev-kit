#!/usr/bin/env bash

BREWS=("kubectl" "docker-machine-driver-vmware" "docker-compose" "cilium-cli" "hubble" "linkerd" "helm" "zsh-completions " "zsh-autocomplete " "docker-credential-helper " "docker-credential-helper-ecr " "zsh-git-prompt " "terminal-notifier" "int128/kubelogin/kubelogin")
ARCH="$1"

brew_install () {
    brew update && brew upgrade
    for i in "${BREWS[@]}"
    do
        echo "---[Installing $i]---"
        brew install $i >/dev/null
    done
}

install_docker(){
	wget "https://desktop.docker.com/mac/main/$ARCH/Docker.dmg?utm_source=docker&utm_medium=webreferral&utm_campaign=docs-driven-download-mac-$ARCH"
	sudo hdiutil attach Docker.dmg
	sudo /Volumes/Docker/Docker.app/Contents/MacOS/install --accept-license
	sudo hdiutil detach /Volumes/Docker
	echo "docker: INSTALLED"
}

install_minikube(){
	echo "Installing MiniKube"
	curl -LO "https://storage.googleapis.com/minikube/releases/latest/minikube-darwin-$ARCH"
	sudo install "minikube-darwin-$ARCH" /usr/local/bin/minikube

	# Reset PATH since minikubes installer binary weridly puts /opt/google-cloud-sdk/bin at the front
	sed -e 's|^\s*export\s+PATH.*||g' ~/.zshrc
	sed -e 's|^\s*export\s+PATH.*||g' ~/.bashrc
	export PATH="$(echo $PATH | sed -e 's|^/opt/google-cloud-sdk/bin:||g'):/opt/google-cloud-sdk/bin"
	echo "export PATH=$PATH:/opt/google-cloud-sdk/bin" >> ~/.zshrc
	export PATH="$(echo $PATH | sed -e 's|^/opt/google-cloud-sdk/bin:||g'):/opt/google-cloud-sdk/bin"
	echo "export PATH=$PATH:/opt/google-cloud-sdk/bin" >> ~/.bashrc
	export PATH="$(echo $PATH | sed -e 's|^/opt/google-cloud-sdk/bin:||g'):/opt/google-cloud-sdk/bin"
	source ~/.bashrc
}

install_homebrew(){
	/usr/bin/env bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
	echo "homebrew: INSTALLED"
}

install_ohmyzsh(){
	sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
	echo "ohmyzsh: INSTALLED"
}

install_completions(){
    echo "installing completions"
	curl -L https://raw.githubusercontent.com/docker/machine/v0.16.0/contrib/completion/zsh/_docker-machine > ~/.zsh/completion/_docker-machine
}

add_helm_repos () {
    echo "---[Updating Charts]---"
	helm repo add gitlab https://charts.gitlab.io >/dev/null
	helm repo add jetstack https://charts.jetstack.io >/dev/null
	helm repo add prometheus-community https://prometheus-community.github.io/helm-charts >/dev/null
	helm repo add jaegertracing https://jaegertracing.github.io/helm-charts >/dev/null
	helm repo add elastic https://helm.elastic.co >/dev/null
	helm repo add incubator https://charts.helm.sh/incubator >/dev/null
	helm repo add bitnami https://charts.bitnami.com/bitnami >/dev/null
	helm repo add jaegertracing https://jaegertracing.github.io/helm-charts >/dev/null
	helm repo add external-secrets https://charts.external-secrets.io >/dev/null
	helm repo add cilium https://helm.cilium.io/ >/dev/null
	helm repo add fluent https://fluent.github.io/helm-charts >/dev/null
	helm repo add jupyterhub https://jupyterhub.github.io/helm-chart/ >/dev/null
	helm repo add open-metadata https://helm.open-metadata.org/
	helm repo add metabase https://pmint93.github.io/helm-charts >/dev/null # metabase does not currently support an official helm chart
	#helm repo add bespin https://charts.va.th.ten >/dev/null
	helm repo update
}

prereqs(){
	echo "---[Pre-requisites]---"
	(curl --fail -s https://git.va.th.ten >/dev/null && echo " [X] : vpn-access") || (echo " [ ] : vpn-access\n     ERROR: Can't reach TEN, make sure you're on the VPN" && exit 1)

	echo "---[Required Tools]---"
    # Install MiniKube
    if command -v minikube >/dev/null 2>&1 ; then
		echo " [x] : minikube"
    else
        echo "minikube: NOT INSTALLED"
        install_minikube > ./logs/install.log
    fi
    # Install Homebrew
    if command -v brew >/dev/null 2>&1 ; then
		echo " [x] : homebrew"
    else
        echo "homebrew: NOT INSTALLED"
        install_homebrew >> ./logs/install.log
    fi
    # Install Docker
    if command -v docker >/dev/null 2>&1 ; then
		echo " [x] : docker"
    else
        echo "docker: NOT INSTALLED"
        install_docker >> ./logs/install.log
    fi
    brew_install >> ./logs/install.log 2>&1
	add_helm_repos >> ./logs/install.log 2>&1
	chmod o-r ~/.kube/config
	chmod g-r ~/.kube/config
}

prereqs
