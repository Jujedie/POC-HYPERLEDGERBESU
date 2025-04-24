#!/bin/bash
RPC_URL="http://localhost:8545"

echo "Configuration de Nginx"

while true; do
	# Écriture de la première partie du fichier

cat <<EOF > ./nginx.conf
worker_processes 1;

events {
  worker_connections 1024;
}
http {
	server {
		listen 80;
		location / {
EOF

	# Ajout de la liste des adresses IP des noeuds au fichier de configuration 
	PEERS=$(curl -s -X POST --data '{"jsonrpc":"2.0","method":"admin_peers","params":[],"id":1}' $RPC_URL \
	  | jq -r '.result[].network.remoteAddress' | cut -d: -f1 | sort | uniq)

	for ip in $PEERS; do
		echo "ip: $ip"
		echo "			allow $ip;" >> ./nginx.conf
	done

	# Écriture de la deuxième partie du fichier | deny all;

host= "\$host"
remote_addr= "\$remote_addr"

cat <<EOF >> ./nginx.conf
			

			proxy_pass http://127.0.0.1:8545;
			proxy_set_header Host $host;
			proxy_set_header X-Real-IP $remote_addr;
		}
		location /[qbft] {
EOF
	# Ajout de la liste des adresses IP des noeuds validateurs au fichier de configuration

	VALIDATORS=$(curl -s -X POST -H "Content-Type: application/json" \
	  --data '{"jsonrpc":"2.0","method":"qbft_getValidatorsByBlockNumber","params":["latest"],"id":1}' \
	  $RPC_URL | jq -r '.result[]')

	PEERS=$(curl -s -X POST --data '{"jsonrpc":"2.0","method":"admin_peers","params":[],"id":1}' $RPC_URL \
		| jq -r '.result[] | "\(.network.remoteAddress),\(.id)"' | sort | uniq)

	for peer in $PEERS; do
		peer_id=$(echo "$peer" | cut -d, -f2)
		peer_id=$(echo "$peer_id" | xxd -r -p)
		peer_ip=$(echo "$peer" | cut -d, -f1)

		hash_bin=$(printf '%s' "$peer_id"  | openssl dgst -binary -sha3-256)
		addr_hex=$(printf '%s' "$hash_bin" | tail -c 20 | xxd -p)
		addr="0x${addr_hex,,}"

		echo "ip: $peer_ip"
		echo "addr: $addr"

		if is_validator "$addr" "$VALIDATORS"; then
			echo "			allow $peer_ip;" >> ./nginx.conf
		fi
	done

	# Écriture de la troisième partie du fichier | deny all;

cat <<EOF >> ./nginx.conf
			
			
			proxy_pass http://127.0.0.1:8545;
		}
	}
}
EOF

	docker exec nginx nginx -t
	docker exec nginx nginx -s reload
	sleep 50
done


is_validator() {
  local addr=$1
  local validators=$2
  for v in $validators; do
    [[ "$v" == "$addr" ]] && return 0
  done
  return 1
}