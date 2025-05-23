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

