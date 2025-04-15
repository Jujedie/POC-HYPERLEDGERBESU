IP=$(ip a | grep -oP '(?<=inet\s)\d+(\.\d+){3}' | sed -n '2p')
# -oP: option to use Perl regex and output only the matching part
# '(?<=inet\s)\d+(\.\d+){3}': regex to match the IP address
# sed -n '2p': print only the second line of the output


while ! docker compose logs | grep -q "Enode URL" log; do sleep 1; done
ENODE=$(docker compose logs | grep "Enode URL" | cut -d '|' -f 5 | cut -d ' ' -f 4)
echo "$ENODE@$IP:$2" > /opt/besu/data/$1/enodeUrl.txt
echo "Enode URL: $ENODE"