#!/bin/bash

# Function to display usage/help
usage() {
  echo "Usage: $0 [--ip <ip>] [--rpc-port <port>] [--password <password>] <login> <method> [params] "
  echo "  <login>    - The username for authentication"
  echo "  <method>   - The JSON-RPC method to call"
  echo "  [params]   - Optional parameters for the JSON-RPC method (can be passed as space-separated values)"
  echo "  [--ip]     - Optional IP address (default from .env if not provided)"
  echo "  [--rpc-port] - Optional RPC port (default from .env if not provided)"
  echo "  [--password] - Optional password (will prompt if not provided)"
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
    --password|-p)
      PASSWORD="$2"
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

if [[ -z "$PASSWORD" ]]; then
  echo -n "Password: "
  read -s PASSWORD
  echo ""
fi

# Fetch the authentication token using the provided username and password
TOKEN=$(curl -k -X POST --data '{"username":"'"$1"'","password":"'"$PASSWORD"'"}' https://$IP_EXTERNE:$RPC_PORT/login 2>/dev/null | jq .token 2>/dev/null | tr -d '"')

# Check if token retrieval was successful
if [[ -z "$TOKEN" ]]; then
  echo "Error: Failed to retrieve token. Please check your credentials."
  exit 1
fi

# Collect parameters for the JSON-RPC method (starting from the 4th argument)
params_json=$(printf '%s\n' "${@:3}" | jq -R . | jq -s .)

# Call the JSON-RPC method and display the result
curl -k -X POST -H "Authorization: Bearer $TOKEN" \
  --data '{"jsonrpc":"2.0","method":"'"$2"'","params":'"$params_json"',"id":1}' \
  https://$IP_EXTERNE:$RPC_PORT 2>/dev/null | jq .result
