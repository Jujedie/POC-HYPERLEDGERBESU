# PoC-HyperledgerBesu

Avant de commencer, assurez-vous d'être sur une machine Linux,
et d'avoir un compte sudoer.

## Installation

Après avoir cloner ce répertoire, exécutez les commandes suivante pour installer les dépendances :

```bash
chmod +x installationPaquets.sh
sh installationPaquets.sh
```

A la suite de l'installation, vous devez redémarrer votre machine.

## Lancement du projet

Pour lancer ce projet, tout d'abord rendez vous dans le dossier besu-node :

```bash
cd ./besu-node
```

Si vous voulez vous renseigner sur les divers commandes éxécutez la commande suivante :

```bash
sh besu.sh --help
```

### Création de la blockchain

Pour initialiser une blockchain, exécutez la commande suivante :

```bash
sh besu --new <EST_VALIDATEUR>
```

Lors de la création d'une blockchain le noeud initial sera un bootnode (nœud de démarrage).

Additionnellement, vous pouvez spécifier le port rpc, p2p. 

```bash
sh besu --new <EST_VALIDATEUR> --rpc-port <PORT> --p2p-port <PORT>
```

### Joindre une blockchain existante

Pour rejoindre une blockchain existante, exécutez la commande suivante :

```bash
sh besu --join <ENODE_URL_BOOTNODE> <EST_BOOTNODE> <EST_VALIDATEUR>
```

Il est conseillé de spécifier un enode d'un bootnode, l'enode peut être retrouver dans le répertoire ./data-node/Node-[NUMERO]/data/enodeUrl.txt.

Il est impératif de spécifier le port rpc, p2p et metric si vous souhaitez éxécuter plusieurs noeuds sur une même machine, pour cela exécutez la commande suivante :

```bash
sh besu --join <ENODE_URL_BOOTNODE> <EST_BOOTNODE> <EST_VALIDATEUR> --rpc-port <PORT> --p2p-port <PORT> --metric-port <PORT> --num-dir <NUMERO>
```

### Démarrer un nœud

Pour démarrer un noeud assurez vous d'avoir un noeud préalablement créé, puis exécutez la commande suivante :

```bash
sh besu --start <EST_BOOTNODE> --num-dir <NUMERO>
```

Le numéro de répertoire est nécessaire si le noeud a démarré est dans un répertoire autre que ./data-node/Node-1

### Arrêter un noeud

Pour arreter un noeud vous pouvez utiliser docker rm pour supprimer le container ou utiliser docker compose down -v.
Cependant docker compose down -v enlève tous les containers créés.

```bash
docker compose down -v
```

## Accéder aux métriques de la blockchain

Pour accéder aux métriques de la blockchain, vous devez d'abord avoir démarré une blockchain.

Ensuite rendez vous à l'adresse suivante :
http://localhost:3000

le mot de passe et l'identifiant peuvent être changé dans compose.yaml.

Le mot de passe et l'identifiant par défaut est : admin

Allez dans la catégorie ... (à continuer)
<!--
Le nombre de nœuds au minmum 4
```bash
sh create.sh [nombre de nœuds]
``` 
-->