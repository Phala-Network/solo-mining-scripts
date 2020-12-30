#!/bin/bash

basedir=$(cd `dirname $0`;pwd)
scriptdir=$basedir/scripts
installdir=/opt/phala
source $scriptdir/utils.sh

help()
{
cat << EOF
Usage:
    help                            show install help information ｜ 展示帮助信息
EOF
exit 0
}

install_phala_scripts()
{
    log_info "--------------Install phala node-------------"
    log_info "--------------Install phala 脚本程序-------------"

    if [ -f "$installdir/scripts/uninstall.sh" ]; then
        log_info "Uninstall old phala node"
        log_info "删除旧的 Phala 脚本"
        $installdir/scripts/uninstall.sh
    fi
    log_info "Install new phala node"
    log_info "安装新的 Phala 脚本"
    mkdir -p $installdir
    cp $basedir/config.json $installdir/
    cp -r $basedir/scripts $installdir/
    chmod 777 -R $installdir

    log_info "Install phala command line tool"
    log_info "安装 Phala 命令行工具"
    cp $scriptdir/phala.sh /usr/bin/phala
    chmod 777 /usr/bin/phala

    log_success "------------Install success-------------"
    log_success "------------安装成功-------------"
}

if [ $(id -u) -ne 0 ]; then
    log_err "Please run with sudo!"
    log_err "请使用sudo运行!"
    exit 1
fi

case "$1" in
    help)
        help
        ;;
    "")
        install_phala_scripts
        ;;
    *)
        help
        ;;
esac

exit 0
