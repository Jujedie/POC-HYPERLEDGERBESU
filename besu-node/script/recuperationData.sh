#!/bin/bash

if [ "$(uname -s)" = "Darwin" ]; then
	IP=$(scutil --nwi | grep address | cut -d ':' -f 2 | cut -d ' ' -f 2)
elif [ "$(uname -s)" = "Linux" ]; then
	IP=$(hostname -I | cut -d ' ' -f 1)
else
	echo "OS inconnu"
fi

echo "docker compose logs $3"
while ! docker compose logs $3 | grep -q "Enode URL"; do sleep 1; done

ENODE=$(docker compose logs $3 | grep "Enode URL" | cut -d '|' -f 6 | cut -d ' ' -f 4 | cut -d '@' -f 1)
echo "$ENODE@$IP:$2" > $1/data/enodeUrl.txt

# Extract public key from enode URL
PUBLIC_KEY=$(echo $ENODE | sed 's/enode:\/\///')
echo "0x$PUBLIC_KEY" > $1/data/publicKey.txt

# Try to find node address in logs
NODE_ADDRESS=$(docker compose logs $3 | grep -E "Node address|Ethereum address" | grep -oE "0x[0-9a-fA-F]{40}" | head -1)

# Save node address
if [ -n "$NODE_ADDRESS" ]; then
	echo "$NODE_ADDRESS" > $1/data/nodeAddress.txt
else
	echo "Failed to extract node address from logs" > $1/data/nodeAddress.txt
fi
