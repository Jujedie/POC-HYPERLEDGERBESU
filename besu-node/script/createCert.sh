CERT_DIR="./certs"
PRIVKEY="$CERT_DIR/privkey.pem"
FULLCHAIN="$CERT_DIR/fullchain.pem"

mkdir -p "$CERT_DIR"
openssl req -x509 -newkey rsa:4096 -sha256 -days 365 \
    -nodes -keyout "$PRIVKEY" -out "$FULLCHAIN" \
    -subj "/C=FR/ST=France/L=Paris/O=MonOrganisation/OU=IT/CN=localhost"



