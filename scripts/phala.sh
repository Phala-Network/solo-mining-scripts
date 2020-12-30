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
    help                            show help information ｜ 展示帮助信息
    install {init|isgx|dcap}        install your phala node ｜ 安装Phala挖矿套件
    start {node|pruntime|phost}     start your node module ｜ 启动挖矿
    stop {node|pruntime|phost}		use docker kill to stop module ｜ 停止挖矿程序
	config							configure your phala node ｜ 配置
    status							show module configurations ｜ 查看挖矿套件运行状态
    update {clean}					update phala node ｜ 升级
    logs {node|pruntime|phost}		show node module logs ｜ 打印log信息
EOF
exit 0
}

sgx_test()
{
	docker -v
	if [ $? -ne 0 ]; then
        log_err "----------docker not install----------"
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
			log_err "----------sgx driver not install----------"
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