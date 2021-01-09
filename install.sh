#!/bin/bash

basedir=$(cd `dirname $0`;pwd)
scriptdir=$basedir/scripts
installdir=/opt/phala

help()
{
cat << EOF
Usage:
    cn                              install chinese phala script | 中文安装
    en                              install english phala script | 英文安装
    help                            show install help information ｜ 展示帮助信息
EOF
exit 0
}

install_cnphala_scripts()
{
    echo "--------------安装 phala 脚本程序-------------"

    if [ -f "$installdir/scripts/uninstall.sh" ]; then
        echo "删除旧的 Phala 脚本"
        $installdir/scripts/uninstall.sh
    fi
    echo "安装新的 Phala 脚本"
    mkdir -p $installdir
    cp $basedir/config.json $installdir/
    cp -r $basedir/scripts/cn $installdir/
    chmod 777 -R $installdir

    echo "安装 Phala 命令行工具"
    cp $scriptdir/cn/phala.sh /usr/bin/phala
    chmod 777 /usr/bin/phala

    echo "------------安装成功-------------"
}

install_enphala_scripts()
{
    echo "--------------Install phala node-------------"

    if [ -f "$installdir/scripts/uninstall.sh" ]; then
        echo "Uninstall old phala node"
        $installdir/scripts/uninstall.sh
    fi
    echo "Install new phala node"
    mkdir -p $installdir
    cp $basedir/config.json $installdir/
    cp -r $basedir/scripts/en $installdir/
    chmod 777 -R $installdir

    echo "Install phala command line tool"
    cp $scriptdir/en/phala.sh /usr/bin/phala
    chmod 777 /usr/bin/phala

    echo "------------Install success-------------"
}

if [ $(id -u) -ne 0 ]; then
    echo "Please run with sudo!"
    echo "请使用sudo运行!"
    exit 1
fi

case "$1" in
    help)
        help
        ;;
    "cn")
        install_cnphala_scripts
        ;;
    "en")
        install_enphala_scripts
        ;;
    *)
        help
        ;;
esac

exit 0
