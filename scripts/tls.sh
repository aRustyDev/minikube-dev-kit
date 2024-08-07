#!/usr/env/bin bash

if [ "$1" == "" ]; then
    echo "Usage: $0 <namespace> <domain>"
    exit 1
fi

if [ "$1" == "up" ]; then
    # TODO: Create a CA cert and sign the certs with it
    # https://docs.openssl.org/1.1.1/man5/x509v3_config
    # https://security.stackexchange.com/questions/252622/what-is-the-purpose-of-certificatepolicies-in-a-csr-how-should-an-oid-be-used
    cat << EOF > secrets/data/minikube.tls.cnf
[req]
distinguished_name = req_distinguished_name
req_extensions = v3_req
prompt = no

[req_distinguished_name]
C = US
O = CISA
OU = CFS
CN = $2

[v3_req]
keyUsage = keyEncipherment, dataEncipherment
extendedKeyUsage = serverAuth
subjectAltName = @alt_names

[alt_names]
DNS.1 = memphis.$2
DNS.2 = metabase.$2
DNS.3 = metadata.$2
DNS.4 = spark.$2
DNS.5 = pgsql.db.$2
DNS.6 = mage.$2
DNS.7 = passbolt.$2
DNS.8 = api.passbolt.$2
EOF

    # Generate the private key
    # openssl genpkey -algorithm ED25519 > secrets/data/minikube.key
    echo "Creating Priv Key"
    openssl genpkey -algorithm RSA -pkeyopt rsa_keygen_bits:2048 > secrets/data/minikube.key

    # Create the CSRs
    echo "Creating CSR"
    openssl req -new -out secrets/data/minikube.csr -key secrets/data/minikube.key -config secrets/data/minikube.tls.cnf
    # openssl req -new -out secrets/data/metabase.csr -key secrets/data/metabase.key -config secrets/data/metabase.tls.cnf
    # openssl req -new -out secrets/data/metadata.csr -key secrets/data/metadata.key -config secrets/data/metadata.tls.cnf
    # openssl req -new -out secrets/data/memphis.csr -key secrets/data/memphis.key -config secrets/data/memphis.tls.cnf
    # openssl req -new -out secrets/data/spark.csr -key secrets/data/spark.key -config secrets/data/spark.tls.cnf
    # openssl req -new -out secrets/data/pgsql.csr -key secrets/data/pgsql.key -config secrets/data/pgsql.tls.cnf
    # openssl req -new -out secrets/data/mage.csr -key secrets/data/mage.key -config secrets/data/mage.tls.cnf

    # Create the certificate
    echo "Creating Pub Key"
    openssl x509 -req -days 7 -in secrets/data/minikube.csr -signkey secrets/data/minikube.key -out secrets/data/minikube.crt

    echo "Creating Kubectl Secret"
    kubectl create secret tls "minikube-tls" \
        -n "$3" \
        --key=secrets/data/minikube.key \
        --cert=secrets/data/minikube.crt \
        -o yaml \
        --dry-run=client > secrets/minikube-tls.yaml

    # Add Cert to Keychain
    echo "Adding Cert to Keychain"
    sudo security add-trusted-cert \
        -r trustRoot \
        -k /Library/Keychains/System.keychain \
        secrets/data/minikube.crt
        # -d : might add this? not sure if admin cert store is needed
    exit 0
fi

if [ "$1" == "down" ]; then
    # Remove Cert from Keychain
    sudo security remove-trusted-cert secrets/data/minikube.crt
    exit 0
fi
