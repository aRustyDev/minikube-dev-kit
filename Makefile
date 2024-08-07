DOMAIN=pi3.mk

install:
	@bash scripts/install.sh || exit 1

verify:
	@bash scripts/verify.sh || exit 1

update: verify
	@bash scripts/update.sh || exit 1

test:
	@bash scripts/tls.sh $$DOMAIN || exit 1

datapipe: verify
	@bash scripts/modify_docker.sh up || exit 1
	@bash scripts/setup.sh || exit 1
	@sudo ./scripts/modify_dns.sh up $$DOMAIN || exit 1
	@bash scripts/tls.sh up $$DOMAIN datapipe || exit 1
	@kubectl apply -f dns/ingress/datapipe/
	@kubectl apply -f secrets/
	@kubectl apply -f secrets/datapipe/
	@helmfile init -f helm/datapipe/
	@helmfile apply -f helm/datapipe/

rebuild: clean
	@bash scripts/modify_docker.sh up || exit 1
	@bash scripts/setup.sh || exit 1
	@sudo ./scripts/modify_dns.sh up $$DOMAIN || exit 1
	@bash scripts/tls.sh up $$DOMAIN || exit 1
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
