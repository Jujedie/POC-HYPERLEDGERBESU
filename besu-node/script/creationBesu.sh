#!/bin/bash

echo "Création d'une nouvelle blockchain QBFT..."
    
# Création du fichier de configuration
cat <<EOF > qbftConfigFile.json
{
    "genesis": {
        "config": {
            "chainId": 1337,
            "berlinBlock": 0,
            "qbft": {
                "epochLength": 1,
                "blockperiodseconds": 5,
                "requesttimeoutseconds": 10
            }
        },
        "nonce": "0x0",
        "timestamp": "0x58ee40ba",
        "gasLimit": "0x1fffffffffffff",
        "difficulty": "0x1",
        "mixHash": "0x63746963616c2062797a616e74696e65206661756c7420746f6c6572616e6365",
        "coinbase": "0x0000000000000000000000000000000000000000",
        "alloc": {}
    },
    "blockchain": {
        "nodes": {
            "generate": true,
            "count": 1
        }
    }
}
EOF

# Génération du fichier genesis
besu operator generate-blockchain-config \
  --config-file=qbftConfigFile.json \
  --to=networkFiles \
  --private-key-file-name=key

# déplacement du fichier genesis
mv networkFiles/genesis.json ./config/
mv qbftConfigFile.json ./config/
# Create destination directory if needed
mkdir -p ./data-node/Node-1

# Find and move the key file
KEY_FILE=$(find networkFiles -name "key" -type f)
mv "$KEY_FILE" ./data-node/Node-1/
  
rm -fr networkFiles

echo "Fichier genesis.json créé avec succès dans le répertoire config."
echo "Démarrage du conteneur Besu..."