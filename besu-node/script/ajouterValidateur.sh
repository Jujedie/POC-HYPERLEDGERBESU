#!/bin/bash

# Vérifier les arguments
if [ "$#" -lt 2 ]; then
    echo "Usage: $0 <chemin-nœud> <port-rpc> [ip-validateur:port]"
    exit 1
fi

# Si une URL distante est fournie, l'utiliser, sinon utiliser localhost
RPC_URL=${3:-localhost:$2}

# Tester la connexion RPC
echo "Connexion test au nœud validateur..."
if ! curl -s -X POST --data '{"jsonrpc":"2.0","method":"net_version","params":[],"id":1}' $RPC_URL/ > /dev/null; then
    echo "Erreur: Impossible de se connecter à $RPC_URL"
    echo "Vérifiez que:"
    echo "1. Le nœud est en cours d'exécution"
    echo "2. Le port RPC est ouvert et accessible"
    echo "3. '--rpc-http-host=0.0.0.0' est configuré"
    exit 1
fi

# Afficher la liste actuelle des validateurs
echo "Liste actuelle des validateurs:"
curl -X POST --data '{"jsonrpc":"2.0","method":"qbft_getValidatorsByBlockNumber","params":["latest"], "id":1}' $RPC_URL/

echo -e '\n\n'

# Ajouter le validateur
address=$(cat $1/data/nodeAddress.txt)
echo "Proposition d'ajout du validateur: $address"
curl -X POST --data "{\"jsonrpc\":\"2.0\",\"method\":\"qbft_proposeValidatorVote\",\"params\":[\"$address\", true],\"id\":1}" $RPC_URL/

echo -e '\n\n'

# Vérifier que le nouveau validateur a été ajouté
echo "Vérification de la proposition:"
curl -X POST --data '{"jsonrpc":"2.0","method":"qbft_getValidatorsByBlockNumber","params":["latest"], "id":1}' $RPC_URL/