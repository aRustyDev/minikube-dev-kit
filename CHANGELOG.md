# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- `sigstore` target in makefile.
- CONTRIBUTING guidelines
- ingresses for `datapipe` target

<!-- ### Changed -->

<!-- ### Removed -->

<!-- ### Fixed -->

## [0.3.0] - 2024-08-11

### Added

- `commitlint` support for `pre-commit`
- `commitlint.config.js` to define configuration for `commitlint`
- CA cert creation, to sign TLS certs; still need to figure out browser trust
- helm values for `jetstream`/`nats`
- make target for `jetstream`/`nats`
- ingress & namespace for `jetstream`/`nats`
- FORCE option for `make install`;
- local domains for `jetstream`/`nats`

### Changed

- updated TLS cert Org & OU
- .gitignore to ignore npm dependencies for `commitlint`
- `cleanup.sh` to include process killing of `kubectl port-forward` commands

## [0.2.1] - 2024-08-09

### Fixed

- `make install` target; was broken before this

## [0.2.0] - 2024-08-07

### Added

- `passbolt` target in makefile.
- Secrets/passbolt/.gitkeep for future yaml configs
- Dns/Ingress/passbolt/.gitkeep for future yaml configs
- Helm/passbolt/ helmfile

### Changed

- Created new sections for each major target
- included description of `make clean` target in README.
- included description of `make <target>` target in README.
- Updated TODO doc
- Updated CHANGELOG

## [0.1.1] - 2024-08-07

### Added

- v1.1 TLS support

### Changed

- Makefile to accomadate multiple different targets
- Scripts/ to accomadate multiple different targets
- Secrets/ to accomadate multiple different targets
- Dns/Ingress/ to accomadate multiple different targets
- Helm/ to accomadate multiple different targets

## [0.1.0] - 2024-08-06

### Added

- `datapipe` target in makefile.
- v1.0 TLS support

[unreleased]: https://github.com/aRustyDev/minikube-dev-kit/compare/v0.2.0...HEAD
[0.2.0]: https://github.com/aRustyDev/minikube-dev-kit/compare/v0.1.1...v0.2.0
[0.1.1]: https://github.com/aRustyDev/minikube-dev-kit/compare/v0.1.0...v0.1.1
[0.1.0]: https://github.com/aRustyDev/minikube-dev-kit/compare/v0.1.0
