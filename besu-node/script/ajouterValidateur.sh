#!/bin/bash

# Si une URL distante est fournie, l'utiliser, sinon utiliser localhost
RPC_URL=${3:-localhost:$2}

# Afficher la liste actuelle des validateurs
curl -X POST --data '{"jsonrpc":"2.0","method":"qbft_getValidatorsByBlockNumber","params":["latest"], "id":1}' $RPC_URL/

echo  $("\n\n\n")

# Ajouter le validateur
address=$(cat $1/data/nodeAddress.txt)
curl -X POST --data "{\"jsonrpc\":\"2.0\",\"method\":\"qbft_proposeValidatorVote\",\"params\":[\"$address\", true],\"id\":1}" $RPC_URL/

echo  $("\n\n\n")

# Vérifier que le nouveau validateur a été ajouté
curl -X POST --data '{"jsonrpc":"2.0","method":"qbft_getValidatorsByBlockNumber","params":["latest"], "id":1}' $RPC_URL/