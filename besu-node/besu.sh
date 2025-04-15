#!/bin/bash

# Fonction d'aide
show_help() {
  echo "Usage: $0 [OPTIONS]"
  echo "Options:"
  echo "  --new                                   Créer une nouvelle blockchain (par défaut)"
  echo "  --join <ENODE_URL> <IS_BOOT> <IS_VALID> Rejoindre une blockchain existante"
  echo "  --start <IS_BOOT> <IS_VALID>            Démarrer le nœud en mode bootstrap (par défaut: true)"
  echo "  --num-dir <DIR>                         Numéro du répertoire du nœud (défaut: 1)"
  echo "  --rpc-port <PORT>                       Port RPC (défaut: 8545)"
  echo "  --p2p-port <PORT>                       Port P2P (défaut: 30303)"
  echo "  --help                                  Afficher cette aide"
}

# Déclaration des variables
MODE="new"
ENODE_URL=" "
IS_BOOT=false
IS_VALID=false
NUM_DIR="1"
RPC_PORT=8545
P2P_PORT=30303
METRIC_PORT=9545
GRAF_PORT=3000
PROM_PORT=9090

# Analyse des arguments
while [[ $# -gt 0 ]]; do
  key="$1"
  case $key in
    --new)
      MODE="new"
      IS_BOOT=true
      shift
      ;;
    --join)
      MODE="join"
      ENODE_URL="$2"
      IS_BOOT="$3"
      IS_VALID="$4"
      shift 4
      ;;
    --start)
      MODE="start"
      IS_BOOT="$2"
      IS_VALID="$3"
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
echo "IS_BOOT=$IS_BOOT" >> .env
echo "IS_VALID=$IS_VALID" >> .env
echo "ENODE_URL=$ENODE_URL" >> .env
echo "METRIC_PORT=$METRIC_PORT" >> .env
echo "PROM_PORT=$PROM_PORT" >> .env
echo "GRAF_PORT=$GRAF_PORT" >> .env

echo -e "Fichier de configuration écrit avec succès.\n"
cat .env

# Exécution selon le mode choisi
echo "Exécution en mode: $MODE"

if [ ! -d "./data-node/Node-$NUM_DIR/data" ]; then 
  mkdir -p "./data-node/Node-$NUM_DIR/data"; 
fi

case $MODE in
    new)
        echo "Création d'une nouvelle blockchain..."

        sh ./script/creationBesu.sh

        docker compose down -v
        docker compose up -d create-qbft
        docker compose start create-qbft
		docker compose up -d prometheus
		docker compose start prometheus
		docker compose up -d grafana
		docker compose start grafana

        sh ./script/recuperationEnode.sh "./data-node/Node-${NUM_DIR}" "$P2P_PORT"
        ;;
    join)
        echo "Rejoindre une blockchain existante avec enode: $ENODE_URL"

        if [ "$IS_BOOT" = "true" ]; then
            docker compose up -d join-bootnode
            docker compose start join-bootnode
            sh ./script/recuperationEnode.sh "./data-node/Node-${NUM_DIR}" "$P2P_PORT"
        else
            docker compose up -d join-node
            docker compose start join-node
        fi
        ;;
    start)
        echo "Démarrage du nœud existant..."

        docker compose up -d start-node
        docker compose start start-node
        ;;
    *)
        echo -e "Mode non reconnu: $MODE\nFermeture des conteneurs..."

        docker compose down -v
        show_help
        exit 1
        ;;
esac

echo "Opération terminée."
