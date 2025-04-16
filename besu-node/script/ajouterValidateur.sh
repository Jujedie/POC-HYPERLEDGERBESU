#!/bin/bash
IP=$(cat $1/data/enodeUrl.txt | cut -d '@' -f 2)

address=$(cat $1/data/nodeAddress.txt)
curl -X POST --data '{"jsonrpc":"2.0","method":"ibft_proposeValidatorVote","params":["'$address'"],"id":1}' -H "Content-Type: application/json" $IP