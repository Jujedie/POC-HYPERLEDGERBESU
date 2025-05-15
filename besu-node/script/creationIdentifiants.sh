#!/bin/bash

PASSWORD=$(besu password hash --password=$3)

cat <<EOF > $1
[Users.$2]
password = "$PASSWORD"
permissions = ["*:*"]
EOF