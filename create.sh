#!/bin/bash
# https://besu.hyperledger.org/private-networks/tutorials/qbft#1-create-directories - 2025/04/09 - Allan LEGRAND

# Tuer tous les nœuds en cas d'erreur
trap "kill 0" EXIT

command -v besu >/dev/null 2>&1 || { echo >&2 "Besu n'est pas installé"; exit 1; }

nb_node=4
if [[ $# -ge 1 ]]; then
	if [ -n "$1" ] && [ "$1" -eq "$1" ] && [ $1 -ge 4 ] 2>/dev/null; then
		nb_node=$1
	else
		echo "$0: veuillez saisir un nombre de nœud valide (supérieur à 4)"
		exit 0
	fi
else
	echo "Nombre de nœud définit à $nb_node par défaut"
fi

# Création des répertoires
for ((i = 1; i <= $nb_node; i++)); do
	mkdir -p Node-$i/data
done

# Création du fichier de configuration
cat <<EOF > qbftConfigFile.json
{
  "genesis": {
    "config": {
      "chainId": 1337,
      "berlinBlock": 0,
      "qbft": {
        "blockperiodseconds": 2,
        "epochlength": 30000,
        "requesttimeoutseconds": 4
      }
    },
    "nonce": "0x0",
    "timestamp": "0x58ee40ba",
    "gasLimit": "0x47b760",
    "difficulty": "0x1",
    "mixHash": "0x63746963616c2062797a616e74696e65206661756c7420746f6c6572616e6365",
    "coinbase": "0x0000000000000000000000000000000000000000",
    "alloc": {
      "fe3b557e8fb62b89f4916b721be55ceb828dbd73": {
        "privateKey": "8f2a55949038a9610f50fb23b5883af3b4ecb3c3bb792cbcefbd1542c692be63",
        "comment": "private key and this comment are ignored.  In a real chain, the private key should NOT be stored",
        "balance": "0xad78ebc5ac6200000"
      },
      "627306090abaB3A6e1400e9345bC60c78a8BEf57": {
        "privateKey": "c87509a1c067bbde78beb793e6fa76530b6382a4c0241e5e4a9ec0a0f44dc0d3",
        "comment": "private key and this comment are ignored.  In a real chain, the private key should NOT be stored",
        "balance": "90000000000000000000000"
      },
      "f17f52151EbEF6C7334FAD080c5704D77216b732": {
        "privateKey": "ae6ae8e5ccbfb04590405997ee2d52d2b330726137b875053c36d94e974d162f",
        "comment": "private key and this comment are ignored.  In a real chain, the private key should NOT be stored",
        "balance": "90000000000000000000000"
      }
    }
  },
  "blockchain": {
    "nodes": {
      "generate": true,
      "count": $nb_node
    }
  }
}
EOF

# Generation des clefs des nœuds et d'un fichier génésis
besu operator generate-blockchain-config --config-file=qbftConfigFile.json --to=networkFiles --private-key-file-name=key 

# Copie du fichier génésis dans le dossier QBFT-Network
mv networkFiles/genesis.json .

# Copie des clefs dans les dossiers des nœuds
i=1
for key in $(ls networkFiles/keys) 
do
	mv networkFiles/keys/$key/* Node-$i/data
	(( i++ ))
done

rm -fr networkFiles 

# Demarrage du premier, le bootnode
cd Node-1
besu --data-path=data --genesis-file=../genesis.json --rpc-http-enabled --rpc-http-api=ETH,NET,QBFT --host-allowlist="*" --rpc-http-cors-origins="all" --profile=ENTERPRISE | tee log &

# Attendre que besu affiche l'enode URL
while ! grep -q "Enode URL" log; do sleep 1; done
enode_url=$(cat log | grep "Enode URL" | cut -d '|' -f 5 | cut -d ' ' -f 4)

cd ..

# Démarrage de tout les autres nœuds
p2p_port=30303
rpc_http_port=8545
for ((i = 2; i <= $nb_node ; i++)); do
	cd Node-$i
	(( p2p_port ++ ))
	(( rpc_http_port ++ ))
	besu --data-path=data --genesis-file=../genesis.json --bootnodes=$enode_url --p2p-port=$p2p_port --rpc-http-enabled --rpc-http-api=ETH,NET,QBFT --host-allowlist="*" --rpc-http-cors-origins="all" --rpc-http-port=$rpc_http_port --profile=ENTERPRISE > log &
	cd ..
done

# Verification que le serveur fonctionne
curl -X POST --data '{"jsonrpc":"2.0","method":"qbft_getValidatorsByBlockNumber","params":["latest"], "id":1}' localhost:8545/ -H "Content-Type: application/json"

echo ""

for ((i = 1; i <= $nb_node; i++)); do
	echo "Nœud $i ecoute sur le port RPC $((8544 + i))"
done

# Boucle infini pour ne pas activer le trap
while [[ 1 -eq 1 ]]; do
	true		
done

