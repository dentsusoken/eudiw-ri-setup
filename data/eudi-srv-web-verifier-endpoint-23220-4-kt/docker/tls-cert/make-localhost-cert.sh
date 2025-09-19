#!/bin/bash
set -e

STOREPASS="password"
ALIAS="localhost"

# Create configuration file for CSR
cat > san.cnf <<EOF
[ req ]
distinguished_name = req_distinguished_name
x509_extensions = v3_req
prompt = no

[ req_distinguished_name ]
CN = localhost

[ v3_req ]
subjectAltName = @alt_names

[ alt_names ]
DNS.1 = localhost
EOF

# Generate EC private key (secp256r1)
openssl ecparam -name prime256v1 -genkey -noout -out ${ALIAS}.key

# Generate Certificate Signing Request (CSR)
openssl req -new -key ${ALIAS}.key -out ${ALIAS}.csr -config san.cnf

# Generate cerfication file
openssl x509 -req -in ${ALIAS}.csr -signkey ${ALIAS}.key \
  -out ${ALIAS}.crt -days 1095 -sha256 \
  -extfile san.cnf -extensions v3_req

# Create pem file
cat ${ALIAS}.crt ${ALIAS}.key > ${ALIAS}.pem
