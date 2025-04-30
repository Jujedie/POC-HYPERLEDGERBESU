#!/bin/bash


ALL_TYPES="admin debug eth miner net plugins trace txpool web3 qbft"

get_methods() {
	TYPE=$1
	case "$TYPE" in
		admin) echo "addPeer changeLogLevel generateLogBloomCache logsRemoveCache logsRepairCache nodeInfo peers removePeer" ;;
		debug) echo "accountAt accountRange batchSendRawTransaction getBadBlocks getRawBlock getRawHeader metrics replayBlock resyncWorldstate setHead standardTraceBlockToFile standardTraceBadBlockToFile storageRangeAt traceTransaction traceBlock traceBlockByHash traceBlockByNumber" ;;
		eth) echo "accounts blockNumber call chainId coinbase createAccessList estimateGas feeHistory gasPrice getBalance getBlockByHash getBlockByNumber getBlockTransactionCountByHash getBlockTransactionCountByNumber getCode getFilterChanges getFilterLogs getLogs getMinerDataByBlockHash getMinerDataByBlockNumber getProof getStorageAt getTransactionByBlockHashAndIndex getTransactionByBlockNumberAndIndex getTransactionByHash getTransactionCount getTransactionReceipt getUncleByBlockHashAndIndex getUncleByBlockNumberAndIndex getUncleCountByBlockHash getUncleCountByBlockNumber getWork hashrate mining newBlockFilter newFilter newPendingTransactionFilter protocolVersion sendRawTransaction submitHashrate submitWork syncing uninstallFilter" ;;
		miner) echo "changeTargetGasLimit setCoinbase start stop" ;;
		net) echo "enode listening peerCount services version" ;;
		plugins) echo "reloadPluginConfig" ;;
		trace) echo "block call callMany filter get rawTransaction replayBlockTransactions transaction" ;;
		txpool) echo "besuPendingTransactions besuStatistics besuTransactions" ;;
		web3) echo "clientVersion sha3" ;;
		qbft) echo "getPendingVotes getValidatorsByBlockNumber" ;;
		*) echo "" ;;
	esac
}


cli() {
	echo "Types de méthodes disponibles :"
	i=1
	for type in $ALL_TYPES; do
		echo "  $i) $type"
		i=$((i+1))
	done

	echo
	read -p "Entrez les numéros des types séparés par des espaces (ex: 1 3 5): " type_indices

	selected_types=""
	for idx in $type_indices; do
		t=$(echo $ALL_TYPES | cut -d' ' -f$idx)
		selected_types="$selected_types $t"
	done
	for type in $selected_types; do
		echo
		echo "Méthodes disponibles pour le type '$type' :"
		methods=$(get_methods "$type")
		i=1
		for m in $methods; do
			echo "  $i) $m"
			i=$((i+1))
		done
		echo "  *) Toutes les méthodes (* pour tout)"

		read -p "Entrez les numéros des méthodes (ex: 1 3 5 ou *): " method_input

		if [ "$method_input" = "*" ]; then
			formatted_list="${formatted_list}\"$type:*\","
		else
			for mi in $method_input; do
				m=$(echo $methods | cut -d' ' -f$mi)
				if [ -n "$m" ]; then
					formatted_list="${formatted_list}\"$type:$m\","
				fi
			done
		fi
	done
}

tui() {
	selected_types=$(printf "%s\n" $ALL_TYPES | gum choose --no-limit --header "Choisissez les types de méthodes (Naviguer avec les flèches directionnelles et appuyer sur x pour sélectionner les types de méthodes désirées)")

	for type in $selected_types; do
		methods=$(get_methods "$type")

		method_list=$(printf "%s\n" $methods)
		method_list="*\n$method_list"
		selected_methods=$(printf "%b" "$method_list" | gum choose --no-limit --header "Méthodes pour '$type' (choisissez * pour tout ou des méthodes spécifiques)")

		if echo "$selected_methods" | grep -q "^\*$"; then
			formatted_list="${formatted_list}\"$type:*\","
		else
			for m in $selected_methods; do
				formatted_list="${formatted_list}\"$type:$m\","
			done
		fi
	done
}

ask_user_info() {
	echo -n "Entrez le nom d'utilisateur : "
	read USERNAME
	echo -n "Entrez le mot de passe pour l'utilisateur '$USERNAME' : "
	read -s password

	HASHED_PASSWORD=$(besu password hash --password="$password")

	formatted_list=""

	$SELECTOR

	echo "[Users.$USERNAME]" >> auth.toml
	echo "password = \"$HASHED_PASSWORD\"" >> auth.toml
	formatted_list=$(echo "$formatted_list" | sed 's/,$//')
	echo "permissions = [$formatted_list]" >> auth.toml
}

if [ -z "$1" ]; then
	echo "Usage : $0 <nombre d'utilisateurs>"
	exit 1
fi

NUM_USERS=$1

if ! command -v gum &>/dev/null; then
	SELECTOR=cli
else
	SELECTOR=tui
fi



for ((i=1; i<=NUM_USERS; i++)); do
	echo "=== Utilisateur $i ==="
	ask_user_info
done

echo "Fichier 'auth.toml' généré avec succès."
