#!/usr/bin/bash

set -eE -o functrace

failure() {
    local statuscode=$? ; local lineno=$1 ; local msg=$2
    echo "Failed with exit code ($statuscode) at line ($lineno) => $msg"
}

trap 'failure ${LINENO} "$BASH_COMMAND"' ERR

CFG_NAME=lb_${PAAS_SERVICE_ID--}_-

curl -fsSL ${STATIC_URL}/ingress/node_master -o node_master

sed -i -e "s!||NODE_NAME||!$NODE_NAME!g" node_master
sed -i -e "s!||NODE_PORT||!$NODE_PORT!g" node_master

sudo cp node_master /etc/nginx/sites-available/$CFG_NAME
sudo ln -s /etc/nginx/sites-available/$CFG_NAME /etc/nginx/sites-enabled/

rm -f reverse_proxy

sudo nginx -t && sudo nginx -s reload