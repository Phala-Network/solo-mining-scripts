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

	if [ -f /usr/bin/phala ]; then
		echo "删除旧的 Phala 脚本"
		phala uninstall
	fi
	echo "安装新的 Phala 脚本"
	mkdir -p $installdir
	cp $basedir/config.json $installdir/
	cp -r $basedir/scripts/cn $installdir/scripts

	echo "安装 Phala 命令行工具"
	chmod +x $installdir/scripts/phala.sh
	ln -s $installdir/scripts/phala.sh /usr/bin/phala

	echo "------------安装成功-------------"
}

install_enphala_scripts()
{
	echo "--------------Install phala node-------------"

	if [ -f /usr/bin/phala ]; then
		echo "Uninstall old phala node"
		phala uninstall
	fi
	echo "Install new phala node"
	mkdir -p $installdir
	cp $basedir/config.json $installdir/
	cp -r $basedir/scripts/en $installdir/scripts

	echo "Install phala command line tool"
	chmod +x $installdir/scripts/phala.sh
	ln -s $installdir/scripts/phala.sh /usr/bin/phala

	echo "------------Install success-------------"
}

if [ $(id -u) -ne 0 ]; then
	echo "Please run with sudo!"
	echo "请使用sudo运行!"
	exit 1
fi

case "$1" in
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
