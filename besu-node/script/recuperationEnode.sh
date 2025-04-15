#!/bin/bash

if [ "$(uname -s)" = "Darwin" ]; then
	IP=$(scutil --nwi | grep address | cut -d ':' -f 2)
elif [ "$(uname -s)" = "Linux" ]; then
	IP=$(hostname -I | cut -d ' ' -f 1)
else
	echo "OS inconnu"
fi

echo "IP: $IP" > $1/enodeUrl.txt

while ! docker compose logs | grep -q "Enode URL"; do sleep 1; done

ENODE=$(docker compose logs | grep "Enode URL" | cut -d '|' -f 6 | cut -d ' ' -f 4 | cut -d '@' -f 1)
echo "$ENODE@$IP:$2" > $1/enodeUrl.txt
