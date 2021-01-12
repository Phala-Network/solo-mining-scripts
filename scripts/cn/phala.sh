#!/bin/bash

basedir=/opt/phala
scriptdir=$basedir/scripts

source $scriptdir/utils.sh
source $scriptdir/config.sh
source $scriptdir/install_phala.sh
source $scriptdir/start.sh
source $scriptdir/stop.sh
source $scriptdir/update.sh
source $scriptdir/logs.sh
source $scriptdir/status.sh

help()
{
cat << EOF
Usage:
	help							展示帮助信息
	install {init|isgx|dcap}		安装Phala挖矿套件
	uninstall						删除phala脚本
	start {node|pruntime|phost}		启动挖矿
	stop {node|pruntime|phost}		停止挖矿程序
	config							配置
	status							查看挖矿套件运行状态
	update {clean}					升级
	logs {node|pruntime|phost}		打印log信息
EOF
exit 0
}

sgx_test()
{
	docker -v
	if [ $? -ne 0 ]; then
		log_err "----------docker 没有安装----------" 
		exit 1
	fi

	local res=$(ls /dev | grep sgx)
	if [ x"$res" == x"sgx" ]; then
		docker run -ti --rm --name phala-sgx_detect --device /dev/sgx/enclave --device /dev/sgx/provision phalanetwork/phala-sgx_detect
	else
		res=$(ls /dev | grep isgx)
		if [ x"$res" == x"isgx" ];then
			docker run -ti --rm --name phala-sgx_detect --device /dev/isgx phalanetwork/phala-sgx_detect
		else
			log_err "----------sgx 驱动没有安装----------"
			exit 1
		fi
	fi
}

###########################################Switch#########################################

case "$1" in
	install)
		install $2
		;;
	config)
		config $2
		;;
	start)
		start $2
		;;
	stop)
		stop $2
		;;
	status)
		status $@
		;;
	update)
		update $2
		;;
	logs)
		logs $2
		;;
	uninstall)
		$scriptdir/uninstall.sh
		;;
	sgx-test)
		sgx_test
		;;
	help)
		help
		;;
	*)
		help
esac

exit 0