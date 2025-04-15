while ! docker compose logs | grep -q "Enode URL" log; do sleep 1; done
ENODE=$(docker compose logs | grep "Enode URL" | cut -d '|' -f 5 | cut -d ' ' -f 4)
echo "$ENODE" > /opt/besu/data/$1/enodeUrl.txt
echo "Enode URL: $ENODE"