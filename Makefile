MINIKUBE_DOMAIN?=pi3.mk
export MINIKUBE_DOMAIN

install:
	@bash scripts/install.sh || exit 1

verify:
	@bash scripts/verify.sh || exit 1

update: verify
	@bash scripts/update.sh || exit 1

test:
	@echo up $$MINIKUBE_DOMAIN datapipe || exit 1

sigstore: verify
	@bash scripts/modify_docker.sh up || exit 1
	@bash scripts/setup.sh || exit 1
	@sudo ./scripts/modify_dns.sh up $$MINIKUBE_DOMAIN || exit 1
	@bash scripts/tls.sh up $$MINIKUBE_DOMAIN sigstore || exit 1
	@kubectl apply -f secrets/
	@helmfile init -f helm/sigstore/
	@helmfile apply -f helm/sigstore/

passbolt: verify
	@bash scripts/modify_docker.sh up || exit 1
	@bash scripts/setup.sh || exit 1
	@sudo ./scripts/modify_dns.sh up $$MINIKUBE_DOMAIN || exit 1
	@bash scripts/tls.sh up $$MINIKUBE_DOMAIN passbolt || exit 1
	@kubectl apply -f secrets/
	@helmfile init -f helm/passbolt/
	@helmfile apply -f helm/passbolt/

datapipe: verify
	@bash scripts/modify_docker.sh up || exit 1
	@bash scripts/setup.sh || exit 1
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
	@bash scripts/setup.sh || exit 1
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
	@rm secrets/data/*
