#!/bin/bash

if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <address> <ip_validator:port>"
    echo "Example: $0 0x1234567890abcdef1234567890abcdef12345678 127.0.0.1:8545"
    exit 1
fi

address=$1
URL_VALIDATEUR=$2
echo "Address: $address"
echo "RPC URL: $RPC_URL"
echo "Starting validator node..."
curl -X POST --data "{\"jsonrpc\":\"2.0\",\"method\":\"qbft_proposeValidatorVote\",\"params\":[\"$address\", false],\"id\":1}" $URL_VALIDATEUR/
