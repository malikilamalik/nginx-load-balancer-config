#!/usr/bin/bash

set -eE -o functrace

failure() {
    local statuscode=$? ; local lineno=$1 ; local msg=$2
    echo "Failed with exit code ($statuscode) at line ($lineno) => $msg"
}

trap 'failure ${LINENO} "$BASH_COMMAND"' ERR

CFG_NAME=lb_${PAAS_SERVICE_ID--}_-

curl -fsSL https://raw.githubusercontent.com/malikilamalik/nginx-load-balancer-config/main/node

sed -i -e "s!||NODE_NAME||!$NODE_NAME!g" node
sed -i -e "s!||NODE_PORT||!$NODE_PORT!g" node

sudo cp node /etc/nginx/sites-available/$CFG_NAME
sudo ln -s /etc/nginx/sites-available/$CFG_NAME /etc/nginx/sites-enabled/

rm -f reverse_proxy

sudo nginx -t && sudo nginx -s reload