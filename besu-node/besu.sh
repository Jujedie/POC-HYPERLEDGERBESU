#!/bin/bash

# Fonction d'aide
show_help() {
  echo "Usage: $0 [OPTIONS]"
  echo "Options:"
  echo "  --new                                   Créer une nouvelle blockchain (par défaut)"
  echo "  --join <ENODE_URL>                      Rejoindre une blockchain existante"
  echo "  --start <ENODE_URL>                     Démarrer le nœud en mode bootstrap (par défaut: true)"
  echo "  --num-dir <DIR>                         Numéro du répertoire du nœud (défaut: 1)"
  echo "  --rpc-port <PORT>                       Port RPC (défaut: 8545)"
  echo "  --p2p-port <PORT>                       Port P2P (défaut: 30303)"
  echo "  --metric-port <PORT>                    Port Metric (défaut: 9545)"
  echo "  --help                                  Afficher cette aide"
  echo "  --no-nginx							  Ne pas lancer le reverse proxy"
}

# Déclaration des variables
MODE="new"
ENODE_URL=" "
NUM_DIR="1"
RPC_PORT=8545
P2P_PORT=30303
METRIC_PORT=9545
GRAF_PORT=3000
PROM_PORT=9090
NGINX=true
NGINX_PORT=80

# Analyse des arguments
while [[ $# -gt 0 ]]; do
  key="$1"
  case $key in
    --new)
      MODE="new"
      shift 1
      ;;
    --join)
      MODE="join"
      ENODE_URL="$2"
      shift 2
      ;;
    --start)
      MODE="start"
      ENODE_URL="$2"
      shift 2
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
    --help)
      show_help
      exit 0
      ;;
    --validator)
      MODE="validator"
      ENODE_URL="$2"
      shift 2
      ;;
	--no-nginx)
		NGINX=false
		shift 1
		;;
	--nginx-port)
		NGINX_PORT=$2 
		shift 2 
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
echo "NGINX_PORT=$NGINX_PORT" >> .env

if [[ "$(uname -s)" = "Darwin" ]]; then
	IP_EXTERNE=$(scutil --nwi | grep address | cut -d ':' -f 2 | cut -d ' ' -f 2)	
elif [[ "$(uname -s)" = "Linux" ]]; then 
  # Faire un alias de hostname -I qui exécute hostname -i si sur un linux autre que debian
	IP_EXTERNE=$(hostname -i | awk '{print $1}')  
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
        rm -rf ./data-node/Node-*

        echo "Création d'une nouvelle blockchain..."

        sh ./script/creationBesu.sh

        docker compose down -v
        docker compose up -d create-qbft
        docker compose start create-qbft

        sh ./script/recuperationData.sh "./data-node/Node-$NUM_DIR" "create-qbft-$NUM_DIR"
        ;;
    join)
        if [ ! -d "./data-node/Node-$NUM_DIR/data" ]; then 
          mkdir -p "./data-node/Node-$NUM_DIR/data"; 
        fi

        echo "Rejoindre une blockchain existante avec enode: $ENODE_URL" 

        docker compose up -d join-node
        docker compose start join-node
        bash ./script/recuperationData.sh "./data-node/Node-$NUM_DIR" "join-node-$NUM_DIR"
        ;;
    start)
        echo "Démarrage du nœud existant..."

        docker compose up -d start-node
        docker compose start start-node
        ;;
    validator)
        echo "Démarrage du nœud validateur..."

        docker compose up -d validator-node-$NUM_DIR
        docker compose start validator-node-$NUM_DIR
        ;;
    *)
        echo -e "Mode non reconnu: $MODE\nFermeture des conteneurs..."

        docker compose down -v
        show_help
        exit 1
        ;;
esac

if [[ "$NGINX" = true ]]; then
	if ! docker compose ps -a | grep -q nginx; then
		echo "Création et démarrage d'un reverse proxy..."
		docker compose up -d nginx
		docker compose start nginx
	else
		echo "Redémarrage du reverse proxy..."
		docker compose restart nginx	
	fi
	
fi

echo "Opération terminée."

cp ./data-node/Node-$NUM_DIR/key ./data-node/Node-$NUM_DIR/data/privateKey.txt

if ! docker compose ps -a | grep -q prometheus; then
  echo "Creation et démarrage de Prometheus..."
  docker compose up -d prometheus
  docker compose start prometheus
fi

if ! docker compose ps -a | grep -q grafana; then
  echo "Creation et démarrage de Grafana..."
  docker compose up -d grafana
  docker compose start grafana
fi
