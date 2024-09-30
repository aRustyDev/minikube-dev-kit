MINIKUBE_DOMAIN?=pi3.mk
ARCH=$(if [ "${uname -m}" == "x86_64" ],"amd64","arm64")
FORCE?="false"
PLATFORM?="orbstack"
export FORCE
export ARCH
export MINIKUBE_DOMAIN

install:
	@bash scripts/install.sh $$ARCH $$FORCE $(PLATFORM) || exit 1

verify:
	@bash scripts/verify.sh || exit 1

update: verify
	@bash scripts/update.sh || exit 1

test:
	@echo "target is $@, source is $<"

sigstore: verify
	@bash scripts/modify_docker.sh up || exit 1
	@bash scripts/setup.sh $@ || exit 1
	@sudo ./scripts/modify_dns.sh up $$MINIKUBE_DOMAIN || exit 1
	@bash scripts/tls.sh up $$MINIKUBE_DOMAIN sigstore || exit 1
	@kubectl apply -f secrets/
	@helmfile init -f helm/sigstore/
	@helmfile apply -f helm/sigstore/

docker: install verify
	@bash scripts/change_platform_state.sh docker up || exit 1

kubernetes: install verify
	@bash scripts/change_platform_state.sh $(PLATFORM) up || exit 1

tracing:
	@#setup jaeger

vault: verify
	@nohup vault server -dev -dev-root-token-id="dev-only-token" -dev-plugin-dir=./vault/plugins &
	@bash scripts/vault.sh || exit 1

jetstream: verify
	@bash scripts/modify_docker.sh up || exit 1
	@bash scripts/setup.sh $@ || exit 1
	@sudo ./scripts/modify_dns.sh up $$MINIKUBE_DOMAIN || exit 1
	@#bash scripts/tls.sh up $$MINIKUBE_DOMAIN jetstream || exit 1
	@kubectl apply -f k8s/jetstream/namespaces/
	@#kubectl apply -f k8s/jetstream/secrets/
	@kubectl apply -f k8s/jetstream/ingresses/
	@#kubectl apply -f k8s/jetstream/serviceaccounts/
	@#kubectl apply -f k8s/jetstream/rbac/
	@#kubectl apply -f k8s/jetstream/deployments/
	@kubectl apply -f secrets/
	@helmfile init -f helm/jetstream/
	@helmfile apply -f helm/jetstream/
	@helm repo add nats https://nats-io.github.io/k8s/helm/charts/ && helm repo update
	@helm install operator nats/nats-operator --version 0.8.3 -n nats-io --values helm/jetstream/values/operator.yaml --wait
	@sleep 60
	@kubectl port-forward -n nats-io pods/nats-cluster-1 4222:4222 > /dev/null &
	@kubectl port-forward -n nats-io pods/nats-cluster-1 6222:6222 > /dev/null &
	@kubectl port-forward -n nats-io pods/nats-cluster-1 8222:8222 > /dev/null &

admission-controllers: verify vault
	@bash scripts/modify_docker.sh up || exit 1
	@bash scripts/setup.sh $@ || exit 1
	@sudo ./scripts/modify_dns.sh up $$MINIKUBE_DOMAIN || exit 1
	@#bash scripts/tls.sh up $$MINIKUBE_DOMAIN admission-controllers || exit 1
	@kubectl apply -f k8s/admission-controllers/stage-1/namespaces.yaml
	@kubectl apply -f secrets/
	@kubectl apply -f k8s/admission-controllers/stage-1/
	@helmfile init -f helm/admission-controllers/
	@helmfile apply -f helm/admission-controllers/00-admission-controllers.yaml
	@kubectl apply -f k8s/admission-controllers/stage-2/
	@kubectl apply -f k8s/admission-controllers/stage-3/
	@helmfile apply -f helm/admission-controllers/01-admission-controllers.yaml

passbolt: verify
	@bash scripts/modify_docker.sh up || exit 1
	@bash scripts/setup.sh $@ || exit 1
	@sudo ./scripts/modify_dns.sh up $$MINIKUBE_DOMAIN || exit 1
	@bash scripts/tls.sh up $$MINIKUBE_DOMAIN passbolt || exit 1
	@kubectl apply -f secrets/
	@helmfile init -f helm/passbolt/
	@helmfile apply -f helm/passbolt/

datapipe: vault kubernetes
	@#bash scripts/modify_docker.sh up || exit 1
	@#bash scripts/setup.sh $@ || exit 1
	@#sudo ./scripts/modify_dns.sh up $$MINIKUBE_DOMAIN || exit 1
	@#bash scripts/tls.sh up $$MINIKUBE_DOMAIN "datapipe" || exit 1
	@kubectl apply -f dns/ingress/datapipe/
	@kubectl create ns linkerd
	@kubectl apply -f secrets/
	@kubectl apply -f secrets/datapipe/
	@#bash scripts/modify_dns.sh refresh || exit 1
	@helmfile init -f helm/datapipe/
	@helmfile apply -f helm/datapipe/

rebuild: clean
	@bash scripts/modify_docker.sh up || exit 1
	@bash scripts/setup.sh $@ || exit 1
	@sudo ./scripts/modify_dns.sh up $$MINIKUBE_DOMAIN || exit 1
	@bash scripts/tls.sh up $$MINIKUBE_DOMAIN || exit 1
	@kubectl apply -f dns/ingress/
	@kubectl apply -f secrets/
	@helmfile init -f helm/
	@helmfile apply -f helm/

# refresh: run setup w/o deleting old config
clean:
	@bash scripts/cleanup.sh || exit 1
	@bash scripts/tls.sh down || exit 1
	@bash scripts/modify_docker.sh down || exit 1
	@sudo ./scripts/modify_dns.sh down || exit 1
	@if ! [ -z "$( ls 'secrets/data/' )" ]; then rm secrets/data/*; fi
	@if ! [ -z "$( ls k8s/*/secrets/ )" ]; then rm k8s/*/secrets/tls.yaml; fi
