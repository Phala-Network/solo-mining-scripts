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
	help					展示帮助信息
	install {init|isgx|dcap}		安装Phala挖矿套件,默认无需输入IP地址、助记词
	uninstall				删除phala脚本
	start {node|pruntime|phost}{debug}	启动挖矿(debug参数允许输出挖矿套件日志信息)
	stop {node|pruntime|phost}		停止挖矿程序
	config					配置
	status					查看挖矿套件运行状态
	update {clean}				升级
	logs {node|pruntime|phost}		打印log信息
	sgx-test				运行挖矿测试程序
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

	local res_sgx=$(ls /dev | grep -w sgx)
	local res_isgx=$(ls /dev | grep -w isgx)
	if [ x"$res_sgx" == x"sgx" ] && [ x"$res_isgx" == x"" ]; then
		docker run -ti --rm --name phala-sgx_detect --device /dev/sgx/enclave --device /dev/sgx/provision swr.cn-east-3.myhuaweicloud.com/phala/phala-sgx_detect:latest
	elif [ x"$res_isgx" == x"isgx" ] && [ x"$res_sgx" == x"" ]; then
		docker run -ti --rm --name phala-sgx_detect --device /dev/isgx swr.cn-east-3.myhuaweicloud.com/phala/phala-sgx_detect:latest
	else
		log_err "----------sgx/dcap 驱动没有安装----------"
		exit 1
	fi
}

case "$1" in
	install)
		install $2
		;;
	config)
		config $2
		;;
	start)
		shift 1
		start $@
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
