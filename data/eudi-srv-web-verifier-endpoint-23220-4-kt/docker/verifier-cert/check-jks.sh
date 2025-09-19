#!/bin/bash
# JKS の内容を確認するスクリプト
# Usage: ./check-jks.sh <keystore.jks> <storepass> <alias>

JKS_FILE="$1"
STOREPASS="$2"
ALIAS="$3"

if [ -z "$JKS_FILE" ] || [ -z "$STOREPASS" ] || [ -z "$ALIAS" ]; then
  echo "Usage: $0 <keystore.jks> <storepass> <alias>"
  exit 1
fi

echo "=== 1. Keystore 内のエントリ一覧 ==="
keytool -list -v -keystore "$JKS_FILE" -storepass "$STOREPASS"

echo
echo "=== 2. Alias '$ALIAS' の証明書チェーン ==="
keytool -list -rfc -keystore "$JKS_FILE" -storepass "$STOREPASS" -alias "$ALIAS" > /tmp/certchain.pem
openssl crl2pkcs7 -nocrl -certfile /tmp/certchain.pem | openssl pkcs7 -print_certs -noout

echo
echo "=== 3. SAN (Subject Alternative Name) の確認 ==="
openssl x509 -in /tmp/certchain.pem -noout -text | grep -A1 "Subject Alternative Name"

echo
echo "=== 4. 公開鍵の情報 ==="
openssl x509 -in /tmp/certchain.pem -noout -pubkey | openssl pkey -pubin -text -noout

echo
echo "=== 5. チェーンの検証 (自己署名 or 中間CA含むか) ==="
openssl verify -CAfile /tmp/certchain.pem /tmp/certchain.pem

rm -f /tmp/certchain.pem
