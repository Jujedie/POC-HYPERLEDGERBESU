# PoC-HyperledgerBesu

Avant de commencer, assurez-vous d'être sur une machine Linux
et d'avoir un compte sudoer.

## Installation

Après avoir cloné ce répertoire, exécutez les commandes suivantes pour installer les dépendances :

```bash
chmod +x installationPaquets.sh
sh installationPaquets.sh
```

À la suite de l'installation, vous devez redémarrer votre machine.

## Lancement du projet

Pour lancer ce projet, rendez-vous d'abord dans le dossier besu-node :

```bash
cd ./besu-node
```

Si vous souhaitez obtenir des informations sur les différentes commandes, exécutez la commande suivante :

```bash
sh besu.sh --help
```

### Création de la blockchain

Pour initialiser une blockchain, exécutez la commande suivante :

```bash
sh besu --new <REMOVE_NODES>
```

Lors de la création d'une blockchain, le nœud initial sera un bootnode (nœud de démarrage).

Vous pouvez également spécifier le port RPC et le port P2P :

```bash
sh besu --new --rpc-port <PORT> --p2p-port <PORT>
```

Attention : si vous recréez une blockchain le programme ne supprimera pas les noeuds pré-existant, pour empêcher cela écrivez --new true et alors tous les fichiers précédemment créés seront supprimés.

### Rejoindre une blockchain existante

Pour rejoindre une blockchain existante, exécutez la commande suivante :

```bash
sh besu --join <ENODE_URL_BOOTNODE>
```

Il est conseillé de spécifier un enode d'un bootnode. L'enode peut être retrouvé dans le répertoire `./data-node/Node-[NUMERO]/data/enodeUrl.txt`.

Il est impératif de spécifier le port RPC, P2P et metric si vous souhaitez exécuter plusieurs nœuds sur une même machine. Pour cela, exécutez la commande suivante :

```bash
sh besu --join <ENODE_URL_BOOTNODE> --rpc-port <PORT> --p2p-port <PORT> --metric-port <PORT> --num-dir <NUMERO>
```

### Démarrer un nœud

Pour démarrer un nœud, assurez-vous d'en avoir préalablement créé un, puis exécutez la commande suivante :

```bash
sh besu --start <ENODE_URL_BOOTNODE> --num-dir <NUMERO>
```

Le numéro de répertoire est nécessaire si le nœud à démarrer se trouve dans un répertoire autre que `./data-node/Node-1`.

### Arrêter un nœud

Pour arrêter un nœud, vous pouvez utiliser `docker rm` pour supprimer le conteneur ou utiliser `docker compose down -v`.
Cependant, `docker compose down -v` supprime tous les conteneurs créés.

```bash
docker compose down -v
```

## Accéder aux métriques de la blockchain

Pour accéder aux métriques de la blockchain, vous devez d'abord avoir démarré une blockchain.

Ensuite, rendez-vous à l'adresse suivante :
http://localhost:3000

Le mot de passe et l'identifiant peuvent être changés dans `compose.yaml`.

Le mot de passe et l'identifiant par défaut sont : admin

Dans le menu, cliquez sur <kbd>Dashboards > besu</kbd> afin d'accéder aux métriques de la blockchain.

## Démarrer une DApp

Pour démarrer une DApp, rendez-vous dans le dossier DApps à la racine du projet :

```bash
cd ./DApps
```

Ensuite, si vous souhaitez démarrer une DApp en particulier, rendez-vous dans le dossier correspondant, par exemple `validator-dapp`, et exécutez la commande `npm start` :

```bash
cd ./validator-dapp
npm start
```

Cependant, comme le port 3000 est déjà utilisé par Grafana, vous devrez le changer. Il vous sera donc demandé de confirmer si vous souhaitez changer ce port automatiquement.

## Notes

Si la commande ci-dessous ne renvoie rien :
```bash
hostname -I
```

Alors exécutez la commande suivante :
```bash
cat << EOF >> test
hostname() {
        if [[ "$1" == "-I" ]]; then
                command hostname -i
        else
                command hostname "$@"
        fi
}
EOF
```
