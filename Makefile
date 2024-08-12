MINIKUBE_DOMAIN?=pi3.mk
ARCH=$(if [ "${uname -m}" == "x86_64" ],"amd64","arm64")
FORCE?="false"
export FORCE
export ARCH
export MINIKUBE_DOMAIN

install:
	@bash scripts/install.sh $$ARCH $$FORCE || exit 1

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
	@kubectl port-forward -n nats-io pods/nats-cluster-1 4222:4222 > /dev/null &
	@kubectl port-forward -n nats-io pods/nats-cluster-1 6222:6222 > /dev/null &
	@kubectl port-forward -n nats-io pods/nats-cluster-1 8222:8222 > /dev/null &

passbolt: verify
	@bash scripts/modify_docker.sh up || exit 1
	@bash scripts/setup.sh $@ || exit 1
	@sudo ./scripts/modify_dns.sh up $$MINIKUBE_DOMAIN || exit 1
	@bash scripts/tls.sh up $$MINIKUBE_DOMAIN passbolt || exit 1
	@kubectl apply -f secrets/
	@helmfile init -f helm/passbolt/
	@helmfile apply -f helm/passbolt/

datapipe: verify
	@bash scripts/modify_docker.sh up || exit 1
	@bash scripts/setup.sh $@ || exit 1
	@./scripts/modify_dns.sh message || exit 1
	@sudo ./scripts/modify_dns.sh up $$MINIKUBE_DOMAIN || exit 1
	@bash scripts/tls.sh up $$MINIKUBE_DOMAIN "datapipe" || exit 1
	@kubectl apply -f dns/ingress/datapipe/
	@kubectl apply -f secrets/
	@kubectl apply -f secrets/datapipe/
	@bash scripts/modify_dns.sh refresh || exit 1
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
