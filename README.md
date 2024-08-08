# Minikube Dev Kit

This is a development kit for the Datapipe project. It contains a set of tools and scripts to help you develop and test the Datapipe project.

## Installation

1. `make install`: this will install the required dependencies for the project. (you will only need to run this once)

> If you are trying to develop this or contribute to the repo
> Run `pip install pre-commit` & `pre-commit install --install-hooks` after you have cloned the repo
> This will install `pre-commit` which is a "package manager" of sorts for git-hooks.
> We use this to help ensure code-quality & to keep our repos clean of secrets

## Usage

### Datapipe

1. `make datapipe`: this will setup the project for development.
2. `make clean` : run this when you're done or want to tear the project down.

This kit is effectively just a Minikube deployment hosted on VMWare (you can swap to VirtualBox if you prefer). The kit is designed to be used with the Datapipe project, but you can use it for other projects if you wish.

To add new components to the project for testing you simply need to create or find a Helm chart to use. You could optionally skip that and add the components manually, but that is not recommended.

When you have identified a new chart to call, you can add its details to the `helm/xx-file.yaml` files. This file is used to define the charts that will be installed when you run `make datapipe`. (the files are processed in alphabetical order, so if you need something to be deployed first put it in the right file)

When you run `make datapipe` you will need to provide your local users password. This is because the script is trying to modify some protected files related to DNS (`/etc/hosts` and `/etc/resolv.conf`). If you are not comfortable with this, you can run the commands manually. When the script is finished it should output an index of the domains that have been created, so you can reach them on your browser.

### Passbolt

1. `make passbolt`: this will setup the project for development.
2. `make clean` : run this when you're done or want to tear the project down.

### Sigstore

1. `make passbolt`: this will setup the project for development.
2. `make clean` : run this when you're done or want to tear the project down.
