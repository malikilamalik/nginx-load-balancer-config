#!/bin/bash
set -eE -o functrace

failure() {
    local statuscode=$? ; local lineno=$2 ; local msg=$3
    echo "Failed with exit code ($statuscode) at line ($lineno) => $msg"
}

trap 'failure ${LINENO} "$BASH_COMMAND"' ERR

mkdir -p $APPLICATION_DIR
cd $APPLICATION_DIR || exit 2

# Install NGINX
sudo apt-get install -qq nginx
sudo ufw allow 'Nginx Full'
sudo systemctl restart nginx