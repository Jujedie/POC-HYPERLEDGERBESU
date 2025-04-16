#!/bin/bash

curl -X POST --data '{"jsonrpc":"2.0","method":"qbft_getValidatorsByBlockNumber","params":["latest"], "id":1}' localhost:$2/

echo  $("\n\n\n")

address=$(cat $1/data/nodeAddress.txt | cut -d 'x' -f 2)
curl -X POST --data "{\"jsonrpc\":\"2.0\",\"method\":\"qbft_proposeValidatorVote\",\"params\":[\"$address\", true],\"id\":1}" localhost:$2/

echo  $("\n\n\n")

# Vérifie si le nouveau validateur a été ajouté
curl -X POST --data '{"jsonrpc":"2.0","method":"qbft_getValidatorsByBlockNumber","params":["latest"], "id":1}' localhost:$2/