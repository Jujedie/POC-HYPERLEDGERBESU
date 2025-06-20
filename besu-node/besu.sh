#!/bin/bash

# Fonction d'aide
show_help() {
  echo "Usage: $0 [OPTIONS]"
  echo "Options:"
  echo "  --new <REMOVE_NODES>                    Créer une nouvelle blockchain (par défaut)"
  echo "  --join <ENODE_URL>                      Rejoindre une blockchain existante"
  echo "  --start <EST_BOOTNODE> <ENODE_URL>      Démarrer le nœud existant, si bootnode veuillez spécifier null comme ENODE_URL"
  echo "  --num-dir <DIR>                         Numéro du répertoire du nœud (défaut: 1)"
  echo "  --rpc-port <PORT>                       Port RPC (défaut: 8545)"
  echo "  --p2p-port <PORT>                       Port P2P (défaut: 30303)"
  echo "  --metric-port <PORT>                    Port Metric (défaut: 9545)"
  echo "  --auth-file <FILE>                      Fichier d'authentification"
  echo "  --nombre-noeuds-max <NOMBRE>            Nombre maximum de nœuds (défaut: 25)"
  echo "  --priv-key-encoding <PASSWORD>          Mot de passe pour le chiffrement de la clé"
  echo "  --help                                  Afficher cette aide"
}

# Déclaration des variables
MODE="new"
REMOVE_NODES="false"
ENODE_URL=" "
NUM_DIR="1"
RPC_PORT=8545
P2P_PORT=30303
METRIC_PORT=9545
GRAF_PORT=3000
PROM_PORT=9090
NB_NODES_MAX=25
AUTH_FILE="auth.toml"
EST_BOOTNODE="false"
ENCODING="PASSWORD"

# Analyse des arguments
while [[ $# -gt 0 ]]; do
  key="$1"
  case $key in
    --new)
      MODE="new"
      REMOVE_NODES="$2"
      shift 2
      ;;
    --join)
      MODE="join"
      ENODE_URL="$2"
      shift 2
      ;;
    --start)
      MODE="start"
      EST_BOOTNODE="$2"
      ENODE_URL="$3"
      shift 3
      ;;
    --num-dir)
      NUM_DIR="$2"
      shift 2
      ;;
    --rpc-port)
      RPC_PORT="$2"
      shift 2
      ;;
    --p2p-port)
      P2P_PORT="$2"
      shift 2
      ;;
    --metric-port)
      METRIC_PORT="$2"
      shift 2
      ;;
    --auth-file)
	    AUTH_FILE="$2"
      shift 2
      ;;
    --priv-key-encoding)
      ENCODING="$2"
      shift 2
      ;;
    --nombre-noeuds-max)
      NB_NODES_MAX="$2"
      shift 2
      ;;
    --help)
      show_help
      exit 0
      ;;
    *)
      echo "Option inconnue: $1"
      show_help
      exit 1
      ;;
  esac
done

# Écriture du fichier de configuration
echo "Écriture du fichier de configuration..."

rm .env
echo "RPC_PORT=$RPC_PORT" > .env
echo "P2P_PORT=$P2P_PORT" >> .env
echo "NUM_DIR=$NUM_DIR" >> .env
echo "ENODE_URL=$ENODE_URL" >> .env
echo "METRIC_PORT=$METRIC_PORT" >> .env
echo "PROM_PORT=$PROM_PORT" >> .env
echo "GRAF_PORT=$GRAF_PORT" >> .env

if [[ "$(uname -s)" = "Darwin" ]]; then
	IP_EXTERNE=$(scutil --nwi | grep address | cut -d ':' -f 2 | cut -d ' ' -f 2)	
elif [[ "$(uname -s)" = "Linux" ]]; then 
  # Faire un alias de hostname -I qui exécute hostname -i si sur un linux autre que debian
	IP_EXTERNE=$(hostname -I 2>/dev/null | awk '{print $1}')  
	if [[ -z "$IP_EXTERNE" ]]; then
		IP_EXTERNE=$(hostname -i | awk '{print $1}')  
	fi
else
	echo "Système inconnu"
	exit 1
fi

# Ajouter l'IP externe à .env
echo "IP_EXTERNE=$IP_EXTERNE" >> .env

echo -e "Fichier de configuration écrit avec succès.\n"
cat .env

# Exécution selon le mode choisi
echo "Exécution en mode: $MODE"

if [ ! -d "./data-node/Node-$NUM_DIR/data" ]; then 
  mkdir -p "./data-node/Node-$NUM_DIR/data"; 
fi

case $MODE in
    new)
        if [ "$REMOVE_NODES" = "true" ]; then
            echo "Suppression des nœuds existants..."
            rm -rf ./data-node/Node-*
        fi

        echo "Création d'une nouvelle blockchain..."

        sh ./script/creationBesu.sh
		
		    cp $AUTH_FILE "./data-node/Node-$NUM_DIR/data/auth.toml"

        docker compose down -v
        docker compose up -d create-qbft
        docker compose start create-qbft

        sh ./script/recuperationData.sh "./data-node/Node-$NUM_DIR" "create-qbft-$NUM_DIR"
        ;;
    join)
        echo "Rejoindre une blockchain existante avec enode: $ENODE_URL" 

		    cp $AUTH_FILE "./data-node/Node-$NUM_DIR/data/auth.toml"

        sleep 2

        docker compose up -d join-node
        docker compose start join-node

        bash ./script/recuperationData.sh "./data-node/Node-$NUM_DIR" "join-node-$NUM_DIR"
        ;;
    start)
        echo "Démarrage du nœud existant..."

        if [ -f "./data-node/Node-$NUM_DIR/key.enc" ]; then
          openssl enc -d -aes-256-cbc -in ./data-node/Node-$NUM_DIR/key.enc -out ./data-node/Node-$NUM_DIR/key -pass pass:$ENCODING
          echo "Clé déchiffrée dans ./data-node/Node-$NUM_DIR/key"
        else
          echo "Fichier ./data-node/Node-$NUM_DIR/key.enc introuvable pour déchiffrement."
        fi

        if [ "$EST_BOOTNODE" = "true" ]; then
            echo "Démarrage en mode bootstrap..."
            docker compose up -d start-bootnode
            docker compose start start-bootnode

            sh ./script/recuperationData.sh "./data-node/Node-$NUM_DIR" "start-bootnode-$NUM_DIR"
        else
            echo "Démarrage en mode normal..."
            docker compose up -d start-node
            docker compose start start-node

            sh ./script/recuperationData.sh "./data-node/Node-$NUM_DIR" "start-node-$NUM_DIR"
        fi

        
        ;;
    *)
        echo -e "Mode non reconnu: $MODE\nFermeture des conteneurs..."

        docker compose down -v
        show_help
        exit 1
        ;;
esac

echo "Opération terminée."

echo "Chiffrement de la clé..."
openssl enc -aes-256-cbc -salt -in ./data-node/Node-$NUM_DIR/key -out ./data-node/Node-$NUM_DIR/key.enc -pass pass:$ENCODING
shred -u ./data-node/Node-$NUM_DIR/key

cd script
bash ./createDashboard.sh --ip $IP_EXTERNE --rpc-port $RPC_PORT Node Node
cd ../