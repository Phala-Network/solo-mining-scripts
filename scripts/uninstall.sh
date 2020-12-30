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
    update_noclean
    rm -r $HOME/phala-node-data
    rm -r $HOME/phala-pruntime-data
    docker image prune -a
    rm $bin_file
fi

rm -rf $installdir

log_info "---------------Uninstall phala node sucess---------------"
