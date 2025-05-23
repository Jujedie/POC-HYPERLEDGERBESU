#!/bin/bash

usage() {
  echo "Usage: $0 [--ip <ip>] [--rpc-port <port>] <password> <login> "
  echo "  <login>    - The username for authentication"
  echo "  <password> - password"
  echo "  [--ip]     - Optional IP address (default from .env if not provided)"
  echo "  [--rpc-port] - Optional RPC port (default from .env if not provided)"
  exit 0
}

# Parse optional IP and RPC port
while [[ $# -gt 0 ]]; do
  case "$1" in
    --ip|-i)
      IP="$2"
      shift 2
      ;;
    --rpc-port|-r)
      PORT="$2"
      shift 2
      ;;
    *)
      break
      ;;
  esac
done

# Set default values for IP and RPC port if not provided
if [[ -z "$IP_EXTERNE" ]]; then
  IP=$(cat ../.env | grep IP_EXTERNE | cut -d '=' -f 2)
fi

if [[ -z "$RPC_PORT" ]]; then
  PORT=$(cat ../.env | grep RPC_PORT | cut -d '=' -f 2)
fi

RESPONSE=$(sh ./rpc.sh --ip $IP --rpc-port $PORT --password $1 $2 "admin_peers")
echo "$RESPONSE"

# Extract all remoteAddress values into a bash array
readarray -t LOCAL_ADDRESSES < <(echo "$RESPONSE" | jq -r '.[]?.network.localAddress // empty')

# If the above does not work (because RESPONSE is a JSON object with .result), use:
# readarray -t REMOTE_ADDRESSES < <(echo "$RESPONSE" | jq -r '.result[]?.network.remoteAddress // empty')

# Print all remote addresses (for debug)
for addr in "${LOCAL_ADDRESSES[@]}"; do
  echo "$addr"
done

# Create the Grafana and Prometheus configuration file

cat <<EOF > ../prometheus/prometheus.yml
global:
  scrape_interval: 15s

scrape_configs:
  - job_name: 'besu'
    static_configs:
      - targets: ['localhost:9545']
  - job_name: 'node'
    static_configs:
      - targets: ['localhost:9100']
EOF

cat <<EOF > ../grafana/datasources.yml
apiVersion1: 1 

datasources:
  - name: DS_PROMETHEUS 
    type: prometheus
    access: proxy
    url: http://localhost:9090
    isDefault: true
EOF

# Create additional scrape configs for each local address

ENTIER=0
for addr in "${LOCAL_ADDRESSES[@]}"; do
  echo "  - job_name: 'besu-$ENTIER'" >> ../prometheus/prometheus.yml
  echo "    static_configs:" >> ../prometheus/prometheus.yml
  echo "      - targets: ['$addr:9545']" >> ../prometheus/prometheus.yml

  echo "  - job_name: 'node-$ENTIER'" >> ../prometheus/prometheus.yml
  echo "    static_configs:" >> ../prometheus/prometheus.yml
  echo "      - targets: ['$addr:9100']" >> ../prometheus/prometheus.yml

  
  echo "  - name: 'DS_PROMETHEUS-$ENTIER'" >> ../grafana/datasource.yml
  echo "    type: prometheus" >> ../grafana/datasources.yml
  echo "    access: proxy" >> ../grafana/datasources.yml
  echo "    url: http://$addr:9090" >> ../grafana/datasources.yml
  echo "    isDefault: false" >> ../grafana/datasources.yml

  sed "s/DS_PROMETHEUS/DS_PROMETHEUS-$ENTIER/g" ../grafana/besu-dashboard.json > ../grafana/besu-dashboard-$ENTIER.json
  

  ENTIER=$((ENTIER + 1))
done

cd ../ 
docker compose down grafana
docker compose down prometheus
docker compose down node-exporter

docker compose up -d grafana
docker compose up -d prometheus
docker compose up -d node-exporter

docker compose start grafana
docker compose start prometheus
docker compose start node-exporter
