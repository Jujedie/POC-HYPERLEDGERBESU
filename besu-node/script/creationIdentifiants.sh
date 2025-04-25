PASSWORD=$(besu password hash --password=Node-$1)
PASSWORD_VALIDATOR=$(besu password hash --password=Node-$1-Validator)

cat <<EOF > ./data-node/Node-$1/data/auth.toml
[Users.Node-$1]
password = "$PASSWORD"
permissions = ["admin:nodeInfo","admin:peers","net:*","eth:*","qbft:getPendingVotes","qbft:getValidatorsByBlockNumber"]
	
[Users.Node-$1-Validator]
password = "$PASSWORD_VALIDATOR"
permissions = ["admin:*","net:*","eth:*","qbft:*"]
EOF