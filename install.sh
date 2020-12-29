#!/bin/bash

basedir=$(cd `dirname $0`;pwd)
scriptdir=$basedir/scripts
installdir=/opt/phala
source $scriptdir/utils.sh

help()
{
cat << EOF
Usage:
    help                            show install help information
EOF
exit 0
}

install_phala_command()
{
    log_info "--------------Install phala node-------------"

    if [ -f "$installdir/scripts/uninstall.sh" ]; then
        echo "Uninstall old phala node"
        $installdir/scripts/uninstall.sh
    fi
    echo "Install new phala node"
    mkdir -p $installdir
    cp $basedir/config.json $installdir/
    cp -r $basedir/scripts $installdir/
    chmod 777 -R $installdir

    echo "Install phala command line tool"
    cp $scriptdir/phala.sh /usr/bin/phala
    chmod 777 /usr/bin/phala

    log_success "------------Install success-------------"
}

if [ $(id -u) -ne 0 ]; then
    log_err "Please run with sudo!"
    exit 1
fi

case "$1" in
    help)
        help
        break;
        ;;
    "")
        shift ;
        break;
        ;;
    *)
        help
        break;
        ;;
esac

install_phala_command
exit 0
