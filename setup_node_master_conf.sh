#!/usr/bin/bash

set -eE -o functrace

failure() {
    local statuscode=$? ; local lineno=$1 ; local msg=$2
    echo "Failed with exit code ($statuscode) at line ($lineno) => $msg"
}

trap 'failure ${LINENO} "$BASH_COMMAND"' ERR

CFG_NAME=lb_${PAAS_SERVICE_ID--}_${NODE_MASTER_NAME--}_${NODE_MASTER_PORT--}

curl -fsSL https://raw.githubusercontent.com/malikilamalik/nginx-load-balancer-config/main/node_master -o node_master
curl -fsSL https://raw.githubusercontent.com/malikilamalik/nginx-load-balancer-config/main/delete_current_conf.sh -o delete_current_conf.sh

sudo bash delete_current_conf.sh

NODE_HOST=""
# Generate Node Host
IFS=';' read -ra NODE <<< "$NODE_INFO"
for n in "${NODE[@]}"; do
    IFS=',' read -ra NAME <<< "$n"
    NODE_HOST+="\tserver ${NAME[0]}:${NAME[1]}\n"
done

sed -i -e "s!||NODE_HOST||!$NODE_HOST!g" node_master
sed -i -e "s!||NODE_MASTER_NAME||!$NODE_MASTER_NAME!g" node_master
sed -i -e "s!||NODE_MASTER_PORT||!$NODE_MASTER_PORT!g" node_master

sudo cp node_master /etc/nginx/sites-available/$CFG_NAME
sudo ln -s /etc/nginx/sites-available/$CFG_NAME /etc/nginx/sites-enabled/

rm -f reverse_proxy

sudo nginx -t && sudo nginx -s reload