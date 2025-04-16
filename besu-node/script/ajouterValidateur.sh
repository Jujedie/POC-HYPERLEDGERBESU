#!/bin/bash

while [[ ! -s $4/data/address.txt ]]; do
    sleep 1
done

address=$(cat $4/data/address.txt)
curl -X POST --data '{"jsonrpc":"2.0","method":"ibft_proposeValidatorVote","params":["'$address'"],"id":1}' -H "Content-Type: application/json" $(cat $2):$3