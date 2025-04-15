ip=$(ip a | grep inet | grep -v inet6 | grep -v 127.0.0.1 | grep -v docker | head -n 1 | cut -d ' ' -f 6)
echo $ip
