#!/bin/bash
set -e

ALIAS="verifier-keystore"
KEY_PASS="verifier"
STORE_PASS="verifier"

# Generate CA private key (P-256)
openssl genpkey \
  -algorithm EC \
  -pkeyopt ec_paramgen_curve:P-256 \
  -out ca-private.key

# Generate CA certificate
openssl req -new -x509 \
  -key ca-private.key \
  -days 1095 \
  -out ca-cert.pem \
  -subj "/CN=CA Root Certificate"

# Generate end-entity private key (P-256)
openssl genpkey \
  -algorithm EC \
  -pkeyopt ec_paramgen_curve:P-256 \
  -out verifier-private.key

# Set password
openssl pkcs8 -topk8 \
  -in verifier-private.key \
  -out verifier-private_protected.key \
  -v2 aes-256-cbc \
  -passout pass:${KEY_PASS}

# Show details of private key
openssl pkey -in verifier-private_protected.key -passin pass:${KEY_PASS} -text -noout

# Generate Certificate Signing Request (CSR) for end-entity certificate
openssl req -new \
  -key verifier-private_protected.key \
  -passin pass:${KEY_PASS} \
  -out verifier.csr \
  -subj "/CN=verifier.eudiw.local"

# Sign the CSR with CA to create end-entity certificate with SAN
openssl x509 -req \
  -in verifier.csr \
  -CA ca-cert.pem \
  -CAkey ca-private.key \
  -CAcreateserial \
  -days 1095 \
  -out verifier-cert.pem \
  -extensions v3_req \
  -extfile <(echo -e "[v3_req]\nsubjectAltName = DNS:Verifier,DNS:verifier.eudiw.local\nkeyUsage = digitalSignature, keyEncipherment")

# Create certificate chain file (end-entity + CA)
cat verifier-cert.pem ca-cert.pem > verifier-chain.pem

# Generate PKCS#12 file
openssl pkcs12 -export \
  -inkey verifier-private_protected.key \
  -passin pass:${KEY_PASS} \
  -in verifier-chain.pem \
  -out verifier-keystore.p12 \
  -name ${ALIAS} \
  -passout pass:${STORE_PASS}

# Convert PKCS#12 file to Java Key Store file
keytool -importkeystore \
  -srckeystore verifier-keystore.p12 \
  -srcstoretype PKCS12 \
  -srcstorepass ${STORE_PASS} \
  -srcalias ${ALIAS} \
  -destalias ${ALIAS} \
  -deststorepass ${STORE_PASS} \
  -destkeypass ${KEY_PASS} \
  -destkeystore verifier-keystore.jks

# show details of jks file
keytool -list -keystore verifier-keystore.jks -storepass ${STORE_PASS} -v
