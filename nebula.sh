#!/bin/bash

nebula_home="$HOME/apps/nebula"
mkdir -p $nebula_home
cd $nebula_home

if [ -e "$nebula_home/nebula" ]; then
  echo "nebula binary exists."
else
    # download binarys
    wget -q https://github.com/slackhq/nebula/releases/download/v1.5.2/nebula-linux-amd64.tar.gz
    tar -xzvf nebula-linux-amd64.tar.gz && rm nebula-linux-amd64.tar.gz && chmod a+x *
    echo "binary downloaded."
fi
if [ -e "$nebula_home/config.yaml" ]; then
  echo "nebula config exists."
else
    # download config
    wget -q https://raw.githubusercontent.com/slackhq/nebula/master/examples/config.yml -O config.yaml
    echo "config downloaded."
fi



sudo mkdir -p /etc/nebula
if [ $1 = "lighthouse" ]; then
    echo "[lighthouse] install...";
    ./nebula-cert ca -name "ybw, Inc"   # gen ca.crt & ca.key
    ./nebula-cert sign -name "lighthouse" -ip "192.168.100.1/24"
    ./nebula-cert sign -name "mac" -ip "192.168.100.2/24"
    ./nebula-cert sign -name "wsl" -ip "192.168.100.3/24"
    ./nebula-cert sign -name "ali" -ip "192.168.100.4/24"
    ./nebula-cert sign -name "cry" -ip "192.168.100.5/24"
    mv ca.key ~

    sed -i "s/am_lighthouse:\ false/am_lighthouse:\ true/g" config.yaml
    sed -i "/\"192.168.100.1\"/d" config.yaml 

    sudo ln -sf ~/apps/nebula/config.yaml /etc/nebula/config.yaml

    sudo cp ca.crt /etc/nebula/ca.crt
    sudo mv lighthouse.crt /etc/nebula/host.crt
    sudo mv lighthouse.key /etc/nebula/host.key

    python3 -m http.server 61234

elif [ $1 = "node" ]; then
    echo "[node] install...";
    node_name=$2; server_host=$3
    sudo mkdir -p /etc/nebula
    sudo wget "$server_host:61234/$node_name.key" -O /etc/nebula/host.key
    sudo wget "$server_host:61234/$node_name.crt" -O /etc/nebula/host.crt
    sudo wget "$server_host:61234/ca.crt"         -O /etc/nebula/ca.crt
    if [[ $(uname -a) =~ "Darwin" ]]; then
        sed=gsed;
    fi
    sed -i "s/100.64.22.11/$server_host/g" config.yaml
    sudo ln -sf ~/apps/nebula/config.yaml /etc/nebula/config.yaml
fi



# rm *.key *.crt && rm -f /etc/nebula/*

# if your mac can't connect to wsl, ping nebula_mac_addr in wsl first.
# it could help
