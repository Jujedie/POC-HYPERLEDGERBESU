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
				"epochLength": 1000,
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
	"alloc": {
		"fe3b557e8fb62b89f4916b721be55ceb828dbd73": {
			"privateKey": "8f2a55949038a9610f50fb23b5883af3b4ecb3c3bb792cbcefbd1542c692be63",
			"comment": "private key and this comment are ignored.  In a real chain, the private key should NOT be stored",
			"balance": "0xad78ebc5ac6200000"
		}
	}
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


# Handle all key files, move each to appropriate Node directory
echo "Moving key files to Node directories..."
# Wait for the directory to exist
while [ ! -d "networkFiles/keys/" ]; do
	echo "Waiting for 'networkFiles/key/' directory to be created..."
	sleep 1
done

i=1
for key in $(ls networkFiles/keys) 
do
	mkdir -p ./data-node/Node-$i/data
	mv networkFiles/keys/$key/* ./data-node/Node-$i
	i=$(( i + 1 ))
done

rm -rf networkFiles

echo "Fichier genesis.json créé avec succès dans le répertoire config."
echo "Démarrage du conteneur Besu..."
