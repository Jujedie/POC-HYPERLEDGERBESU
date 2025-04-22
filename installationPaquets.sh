#!/bin/bash

sudo apt-get update

# Installation de Java 17
sudo apt install openjdk-17-jdk 

# Installation de besu
wget https://github.com/hyperledger/besu/releases/download/25.4.0/besu-25.4.0.tar.gz
sudo tar -xvf besu-25.4.0.tar.gz -C /opt
sudo mv /opt/besu-25.4.0 /opt/besu
echo "export PATH=\$PATH:/opt/besu/bin" >> ~/.bashrc

# Installation de Docker

## Add Docker's official GPG key:
sudo apt-get update
sudo apt-get install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

## Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update

sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

sudo usermod -aG docker $USER
sudo service docker restart
docker context use default

echo "Docker installé, veuillez redémarrer votre machine pour que les modifications prennent effet"

# Installation de NodeJS

sudo apt install nvm
sudo apt install npm
sudo apt install npx

source ~/.bashrc