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

install_cn()
{
	echo "--------------安装 phala 脚本程序-------------"

	if [ -f /opt/phala/scripts/phala.sh ]; then
		echo "删除旧的 Phala 脚本"
		/opt/phala/scripts/phala.sh uninstall
	fi
	echo "安装新的 Phala 脚本"
	if [ ! -f $installdir ]; then mkdir -p $installdir; fi
	if [ -f $installdir/.env ]; then
		cp $basedir/{docker-compose.yml,/console.js} $installdir/
	else
		cp $basedir/{.env,docker-compose.yml,/console.js} $installdir/
	fi
	cp -r $basedir/scripts/cn $installdir/scripts

	echo "安装 Phala 命令行工具"
	chmod +x $installdir/scripts/phala.sh
	ln -s $installdir/scripts/phala.sh /usr/bin/phala
	# sed -i '1c NODE_IMAGE=swr.cn-east-3.myhuaweicloud.com/phala/khala-dev-node' $installdir/.env
	# sed -i '2c PRUNTIME_IMAGE=swr.cn-east-3.myhuaweicloud.com/phala/phala-dev-pruntime' $installdir/.env
	# sed -i '3c PHERRY_IMAGE=swr.cn-east-3.myhuaweicloud.com/phala/phala-dev-pherry' $installdir/.env
	# sed -i '4c NODE_VOLUMES=/var/phala-node-data:/root/data' $installdir/.env
	# sed -i '5c PRUNTIME_VOLUMES=/var/phala-pruntime-data:/root/datas' $installdir/.env

	echo "------------安装成功-------------"
}

install_en()
{
	echo "--------------Install phala scripts-------------"

	if [ -f /opt/phala/scripts/phala.sh ]; then
		echo "Uninstall old phala scripts"
		/opt/phala/scripts/phala.sh uninstall
	fi
	echo "Install new phala scripts"
	if [ ! -f $installdir ]; then mkdir -p $installdir; fi
	if [ -f $basedir/.env ]; then
		cp $basedir/{docker-compose.yml,console.js} $installdir/
	else
		cp $basedir/{.env,docker-compose.yml,console.js} $installdir/
	fi
	cp -r $basedir/scripts/en $installdir/scripts

	echo "Install phala command line tool"
	chmod +x $installdir/scripts/phala.sh
	ln -s $installdir/scripts/phala.sh /usr/bin/phala
	# sed -i '1c NODE_IMAGE=phalanetwork/khala-dev-node' $installdir/.env
	# sed -i '2c PRUNTIME_IMAGE=phalanetwork/phala-dev-pruntime' $installdir/.env
	# sed -i '3c PHERRY_IMAGE=phalanetwork/phala-dev-pherry' $installdir/.env
	# sed -i '4c NODE_VOLUMES=/var/phala-node-data:/root/data' $installdir/.env
	# sed -i '5c PRUNTIME_VOLUMES=/var/phala-pruntime-data:/root/data' $installdir/.env

	echo "------------Install success-------------"
}

if [ $(id -u) -ne 0 ]; then
	echo "Please run with sudo!"
	echo "请使用sudo运行!"
	exit 1
fi

case "$1" in
	"cn")
		install_cn
		;;
	"en")
		install_en
		;;
	*)
		help
		;;
esac
