#!/bin/bash

echo "docker logs $2"
while ! docker logs $2 | grep -q "Enode URL"; do sleep 1; done

ENODE=$(docker logs $2 | grep "Enode URL" | cut -d '|' -f 5 | cut -d ' ' -f 4 )
echo "$ENODE" > $1/data/enodeUrl.txt

# Extract public key from enode URL
PUBLIC_KEY=$(echo $ENODE | sed 's/enode:\/\///')
echo "0x$PUBLIC_KEY" > $1/data/publicKey.txt

# Try to find node address in logs
NODE_ADDRESS=$(docker logs $2 | grep -E "Node address|Ethereum address" | grep -oE "0x[0-9a-fA-F]{40}" | head -1)

# Save node address
if [ -n "$NODE_ADDRESS" ]; then
	echo "$NODE_ADDRESS" > $1/data/nodeAddress.txt
else
	echo "Failed to extract node address from logs" > $1/data/nodeAddress.txt
fi
