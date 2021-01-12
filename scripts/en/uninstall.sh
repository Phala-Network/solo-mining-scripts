#!/bin/bash

installdir=/opt/phala
bin_file=/usr/bin/phala
scriptdir=$installdir/scripts

source $scriptdir/update.sh
source $scriptdir/utils.sh

if [ $(id -u) -ne 0 ]; then
    echo "Please run with sudo!"
    exit 1
fi

if [ -f "$bin_file" ]; then
    docker kill phala-phost
    docker kill phala-pruntime
    docker kill phala-node
    docker image prune -a
    rm -r $HOME/phala-node-data
    rm -r $HOME/phala-pruntime-data
    rm $bin_file
fi

rm -rf $installdir

log_success "---------------Uninstall phala node sucess---------------"
