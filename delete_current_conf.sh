#!/usr/bin/bash

set -eE -o functrace

failure() {
    local statuscode=$? ; local lineno=$1 ; local msg=$2
    echo "Failed with exit code ($statuscode) at line ($lineno) => $msg"
}

trap 'failure ${LINENO} "$BASH_COMMAND"' ERR

CFG_NAME=lb_${PAAS_SERVICE_ID--}_-


if test -f "/etc/nginx/sites-enabled/default"; then
    sudo rm -f /etc/nginx/sites-enabled/default
fi

if test -f "/etc/nginx/sites-available/default"; then
    sudo rm -f /etc/nginx/sites-available/default
fi

if test -f "/etc/nginx/sites-enabled/$CFG_NAME"; then
    sudo rm -f /etc/nginx/sites-enabled/$CFG_NAME
fi

if test -f "/etc/nginx/sites-available/$CFG_NAME"; then
    sudo rm -f /etc/nginx/sites-available/$CFG_NAME
fi


sudo nginx -t && sudo nginx -s reload