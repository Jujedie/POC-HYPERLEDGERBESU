#!/bin/bash

# Display usage/help if -h or --help is provided
if [[ "$1" == "-h" ]] || [[ "$1" == "--help" ]]; then
  echo "Usage: $0 <login> <method> [params]"
  echo "  <login>    - The username for authentication"
  echo "  <method>   - The JSON-RPC method to call"
  echo "  [params]   - Optional parameters for the JSON-RPC method (can be passed as space-separated values) (if the params is a string, put in between quote like this '\"some params\"')"
  exit 0
fi

# Ensure at least 2 arguments (login, method) are provided
if [[ $# -lt 2 ]]; then
  echo "Error: Missing arguments."
  echo "Usage: $0 <login> <password> <method> [params]"
  exit 1
fi

echo -n "Password: "
read -s PASSWORD
echo ""

# Fetch the authentication token using the provided username and password
TOKEN=$(curl -X POST --data '{"username":"'"$1"'","password":"'"$PASSWORD"'"}' http://localhost:8545/login 2>/dev/null | jq .token 2>/dev/null | tr -d '"')

# Check if token retrieval was successful
if [[ -z "$TOKEN" ]]; then
  echo "Error: Failed to retrieve token. Please check your credentials."
  exit 1
fi

# Collect parameters for the JSON-RPC method (starting from the 4th argument)
params=("${@:3}")
params_str=$(IFS=,; echo "[${params[*]}]")

IP_EXTERNE=$(cat ../.env | grep IP_EXTERNE | cut -d '=' -f 2)
RPC_PORT=$(cat ../.env | grep RPC_PORT | cut -d '=' -f 2)
# Call the JSON-RPC method and display the result
curl -X POST -H "Authorization: Bearer $TOKEN" --data '{"jsonrpc":"2.0","method":"'"$2"'","params":'"$params_str"',"id":1}' http://$IP_EXTERNE:$RPC_PORT 2>/dev/null | jq .result
