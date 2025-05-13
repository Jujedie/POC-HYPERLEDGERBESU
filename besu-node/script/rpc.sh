#!/bin/bash

# Function to display usage/help
usage() {
  echo "Usage: $0 [--ip <ip>] [--rpc-port <port>] <num_node> <method> [params] "
  echo " <num_node>    - The node number (e.g., 1, 2, 3, etc.)"
  echo " <method>      - The JSON-RPC method to call"
  echo " [params]      - Optional parameters for the JSON-RPC method (can be passed as space-separated values)"
  echo " [--ip]        - Optional IP address (default from .env if not provided)"
  echo " [--rpc-port]  - Optional RPC port (default from .env if not provided)"
  exit 0
}

# Display usage/help if -h or --help is provided
if [[ "$1" == "-h" ]] || [[ "$1" == "--help" ]]; then
  usage
fi

# Parse optional IP and RPC port
while [[ $# -gt 0 ]]; do
  case "$1" in
    --ip|-i)
      IP_EXTERNE="$2"
      shift 2
      ;;
    --rpc-port|-r)
      RPC_PORT="$2"
      shift 2
      ;;
    *)
      break
      ;;
  esac
done

# Ensure at least 2 arguments (login, method) are provided
if [[ $# -lt 2 ]]; then
  echo "Error: Missing arguments."
  usage
fi

# Set default values for IP and RPC port if not provided
if [[ -z "$IP_EXTERNE" ]]; then
  IP_EXTERNE=$(cat ../.env | grep IP_EXTERNE | cut -d '=' -f 2)
fi

if [[ -z "$RPC_PORT" ]]; then
  RPC_PORT=$(cat ../.env | grep RPC_PORT | cut -d '=' -f 2)
fi

# Check if IP and RPC port are set
if [[ -z "$IP_EXTERNE" ]] || [[ -z "$RPC_PORT" ]]; then
  echo "Error: IP or RPC port not set and could not be found in .env."
  exit 1
fi

key_pub=$(cat ../data-node/Node-$1/data/RSA_public.pem)
key_priv=$(cat ../data-node/Node-$1/data/RSA_private.pem)
key_priv_2=$(cat ../data-node/Node-$1/data/RSA_private_key.pem)

cd ../jwt

echo "Generating JWT token..."
echo "$key_pub" > ./gen-keys/RSA_public.pem
echo "$key_priv" > ./gen-keys/RSA_private.pem
echo "$key_priv_2" > ./gen-keys/RSA_private_key.pem

TOKEN=$(./gradlew run)
TOKEN=$(echo "$TOKEN" | sed -n 's/.*RSA JWT: \([^ ]*\).*/\1/p')
cd ../script

echo "Token retrieved: $TOKEN"

# Check if token retrieval was successful
if [[ -z "$TOKEN" ]]; then
  echo "Error: Failed to retrieve token. Please check your credentials."
  exit 1
fi

# Collect parameters for the JSON-RPC method (starting from the 4th argument)
params=("${@:3}")
params_str=$(IFS=,; echo "[${params[*]}]")

# Call the JSON-RPC method and display the result
echo "curl -k -X POST -H \"Authorization: Bearer $TOKEN\" --data '{\"jsonrpc\":\"2.0\",\"method\":\"$2\",\"params\":$params_str,\"id\":1}' https://$IP_EXTERNE:$RPC_PORT"
curl -k -X POST -H "Authorization: Bearer $TOKEN" --data '{"jsonrpc":"2.0","method":"'"$2"'","params":'"$params_str"',"id":1}' https://$IP_EXTERNE:$RPC_PORT -H "Content-Type: application/json" 2>/dev/null