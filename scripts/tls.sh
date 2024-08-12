#!/usr/env/bin bash

CA_NAME=minikube-pca
SECRET_PATH="secrets/data"
ACTION="$1"
DOMAIN="$2"
NAMESPACE="$3"
CREATE_CA="$4"
CREATE_CERT="$5"

# Quit script if up/down not specified
if [ "$ACTION" == "" ]; then
    echo "Usage: $0 <namespace> <domain>"
    exit 1
fi

# Create & Provision the Certificates
if [ "$ACTION" == "up" ]; then

    # Quit script if domain not specified
    if [ "$DOMAIN" == "" ]; then
        echo "Error (tls.sh): Domain not specified"
        exit 1
    fi

    # Quit script if namespace not specified
    if [ "$NAMESPACE" == "" ]; then
        echo "Error (tls.sh): Namespace not specified"
        exit 1
    fi
    # Create the Config file for the CA
    cat << EOF > $SECRET_PATH/$CA_NAME.cnf
[req]
distinguished_name  = req_subj
prompt              = no
basicConstraints    = CA:TRUE
keyUsage            = critical, keyCertSign
default_bits        = 4096

[req_subj]
commonName              = "$CA_NAME"
emailAddress            = "admin@example.com"
countryName             = "US"
stateOrProvinceName     = "Virginia"
localityName            = "Reston"
organizationName        = "Scattered-Cats"
organizationalUnitName  = "minikube-dev-kit"

EOF
    # Create the CA Private certificate
    echo ":: Generating CA Private Certificate"
    echo ":: Enter password (2x) for CA Certificate"
    openssl genrsa -aes256 -out $SECRET_PATH/$CA_NAME.key 4096

    # Create the CA Public certificate
    echo ":: Generating CA Public Certificate"
    echo ":: [ CA Private Cert PW ]"
    openssl req -x509 -new -nodes -key $SECRET_PATH/$CA_NAME.key -sha256 -days 90 -out $SECRET_PATH/$CA_NAME.crt -config $SECRET_PATH/$CA_NAME.cnf && sleep 3

    # Quit script if CA Cert failed to create
    if [ ! -e "$SECRET_PATH/$CA_NAME.crt" ]; then
        echo "Error CA Cert failed to create ($SECRET_PATH/$CA_NAME.crt does not exist)"
        ls -al secrets/data/minikube-pca*
        exit 1
    fi
    # https://docs.openssl.org/1.1.1/man5/x509v3_config
    # https://security.stackexchange.com/questions/252622/what-is-the-purpose-of-certificatepolicies-in-a-csr-how-should-an-oid-be-used

    # Create a V3 Extension File
    echo ":: Generating Minikube V3 Extension file"
    cat << EOF > $SECRET_PATH/minikube.v3.ext
[ req ]
authorityKeyIdentifier  = keyid,issuer
distinguished_name      = req_subj
basicConstraints        = CA:FALSE
keyUsage                = keyEncipherment, dataEncipherment
extendedKeyUsage        = serverAuth
subjectAltName          = @alt_names
default_bits            = 4096
prompt                  = no

[req_subj]
commonName              = "$DOMAIN"
emailAddress            = "admin@example.com"
countryName             = "US"
stateOrProvinceName     = "Virginia"
localityName            = "Reston"
organizationName        = "Scattered-Cats"
organizationalUnitName  = "minikube-dev-kit"

[alt_names]
DNS.1 = memphis.$DOMAIN
DNS.2 = metabase.$DOMAIN
DNS.3 = metadata.$DOMAIN
DNS.4 = spark.$DOMAIN
DNS.5 = pgsql.db.$DOMAIN
DNS.6 = mage.$DOMAIN
DNS.7 = passbolt.$DOMAIN
DNS.8 = api.passbolt.$DOMAIN
EOF

    # Generate the minikube private key
    # echo "Generating Minikube Private Certificate"
    # openssl genpkey -algorithm RSA -pkeyopt rsa_keygen_bits:2048 > $SECRET_PATH/minikube.key

    # Create the minikube CSR
    echo ":: Generating Minikube CSR"
    openssl req -new -nodes -out $SECRET_PATH/minikube.csr -newkey rsa:4096 -keyout $SECRET_PATH/minikube.key -config $SECRET_PATH/minikube.v3.ext
    # openssl req -new -nodes -out $SECRET_PATH/minikube.csr -key $SECRET_PATH/minikube.key -config $SECRET_PATH/minikube.v3.ext
    # openssl req -new -out $SECRET_PATH/metabase.csr -key $SECRET_PATH/metabase.key -config $SECRET_PATH/metabase.tls.cnf
    # openssl req -new -out $SECRET_PATH/metadata.csr -key $SECRET_PATH/metadata.key -config $SECRET_PATH/metadata.tls.cnf
    # openssl req -new -out $SECRET_PATH/memphis.csr -key $SECRET_PATH/memphis.key -config $SECRET_PATH/memphis.tls.cnf
    # openssl req -new -out $SECRET_PATH/spark.csr -key $SECRET_PATH/spark.key -config $SECRET_PATH/spark.tls.cnf
    # openssl req -new -out $SECRET_PATH/pgsql.csr -key $SECRET_PATH/pgsql.key -config $SECRET_PATH/pgsql.tls.cnf
    # openssl req -new -out $SECRET_PATH/mage.csr -key $SECRET_PATH/mage.key -config $SECRET_PATH/mage.tls.cnf

    # Create the Minikube Public Certificate
    echo ":: Generating Minikube Public Certificate signed by our Private CA"
    echo ":: [ Hint - CA Private Cert PW ]"
    openssl x509 -req -days 7 -in $SECRET_PATH/minikube.csr -CA $SECRET_PATH/$CA_NAME.crt -CAkey $SECRET_PATH/$CA_NAME.key -CAcreateserial -out $SECRET_PATH/minikube.crt -sha256 -extfile $SECRET_PATH/minikube.v3.ext

    # Populate the Minikube public & private key into a kuberenetes TLS secret
    echo ":: Generating Kubectl Secret ('minikube-tls')"
    kubectl create secret tls "minikube-tls" \
        -n "$NAMESPACE" \
        --key=$SECRET_PATH/minikube.key \
        --cert=$SECRET_PATH/minikube.crt \
        -o yaml \
        --dry-run=client > k8s/$NAMESPACE/secrets/tls.yaml

    # Create the Minikube TLS cert
    echo ":: Generating Kubectl Secret ('mkcert')"
    kubectl create secret tls mkcert \
        -n kube-system \
        --key=$SECRET_PATH/minikube.key \
        --cert=$SECRET_PATH/minikube.crt \
        -o yaml \
        --dry-run=client > secrets/minikube-tls.yaml

    # Add CA to keychain
    echo ":: Adding CA to System Keychain"
    echo ":: [ Hint - Localhost PW ]"
    sudo security add-trusted-cert \
        -d -r trustRoot \
        -k /Library/Keychains/System.keychain \
        $SECRET_PATH/$CA_NAME.crt

    # Add Cert to Keychain
    echo ":: Adding Minikube Cert to System Keychain"
    sudo security add-trusted-cert \
        -r trustRoot \
        -k /Library/Keychains/System.keychain \
        $SECRET_PATH/minikube.crt
        # -d : might add this? not sure if admin cert store is needed
    exit 0
fi

if [ "$ACTION" == "down" ]; then
    # Remove CA & Cert from the Keychain
    echo ":: Removing CA & Cert from the System Keychain"
    echo ":: [ Hint - Localhost PW ]"
    for i in $(sudo security find-certificate -a -c $DOMAIN -Z | grep SHA-256 | cut -d " " -f 3);
    do
        sudo security delete-certificate -t -Z $i
    done
    exit 0
fi
