#!/bin/bash

while [[ ! -s $4/data/address.txt ]]; do
    sleep 1
done
curl -X POST --data '{"jsonrpc":"2.0","method":"ibft_proposeValidatorVote","params":["'$1'"],"id":1}' -H "Content-Type: application/json" $(cat $2):$3