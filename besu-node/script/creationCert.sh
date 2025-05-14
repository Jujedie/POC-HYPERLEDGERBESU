CERT_DIR="./certs"
PRIVKEY="$CERT_DIR/priv.key"
CERT_REQ="$CERT_DIR/cert.csr"
CERT="$CERT_DIR/cert.crt"
KEYSTORE="$CERT_DIR/keystore.pfx"
KNOWNCLIENTS="$CERT_DIR/knownClients"
echo -n "Password: "
read -s PASSWORD

mkdir -p "$CERT_DIR"

# Création clef privée 
openssl genrsa -out "$PRIVKEY" 2048

# Création d'une demande de certificat (CSR)
openssl req -new -key "$PRIVKEY" -out "$CERT_REQ" -subj "/CN=localhost" 

# Signature du certificat (auto-signé, valable 1 an)
openssl x509 -req -in "$CERT_REQ" -signkey "$PRIVKEY" -out "$CERT" -days 365

# Convertissement en keystore PKCS12 (besoin de fournir un mot de passe)
openssl pkcs12 -export -in "$CERT" -inkey "$PRIVKEY" -out "$KEYSTORE" -name besuAlias -passout pass:$PASSWORD

echo "$PASSWORD" > "$CERT_DIR/keystorePassword.txt"

openssl x509 -in $CERT -noout -fingerprint -sha256 | cut -d '=' -f 2 > $KNOWNCLIENTS
