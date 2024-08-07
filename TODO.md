# TODO

## Minikube

- [ ] implement for virtualbox driver
- [ ] flesh out vmware driver config options
- [ ] Add config.json/yaml to define minikube hardware requirements for each target (datapipe, passbolt, sigstore, etc)
- [x] Pass domain to tls.sh & modify_dns.sh
- [ ] Add arguments to rebuild target to enable rebuilding TARGET

## Datapipe

- [ ] Implement `helloworld_pyspark.py` to ingest to PySpark from memphis
- [ ] Implement `memphis-producer.go` to ingest local files to memphis
- [ ] Implement `postgres_pyspark.py` to store PySpark transformed data into postgres

## DNS

- [ ] Try swapping NGINX ingress for Traefik ingress

## TLS

- [ ] Add CA Cert before creating TLS certs, then sign w/ it to avoid "self-signed" scenario.
- [ ] Add CA Cert to local trust store
- [ ] Add Cert-Manager to deployment
- [ ] Add Vault access
- [ ] Implement Linkerd2
- [ ] Implement Cilium

## Pre-commit

Search [github](https://github.com/search?q=path%3A.pre-commit-hooks.yaml+language%3AYAML&type=code) for examples

- [ ] `.proto` syntax validation
- [ ] `.proto` variable name linting
- [ ] `.proto` file name linting
- [ ] `.go` syntax validation
- [ ] `.go` variable name linting
- [ ] `.go` file name linting
- [ ] `.go` build verification
- [ ] `.go` test verification
- [ ] `.py` test verification
- [ ] `dns/ingress/*.yaml` kube ingress syntax validation
- [ ] `dns/ingress/*.yaml` opa rule validation
- [ ] `helm/values/*.yaml` Helm Chart Values syntax validation
- [ ] `helm/values/*.yaml` opa rule validation
- [ ] `helm/xx-*.yaml` Helmfile syntax validation
- [ ] `helm/xx-*.yaml` opa rule validation
