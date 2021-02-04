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
	help					show help information
	install {init|isgx|dcap}		install your phala node
	start {node|pruntime|phost}{debug}	start your node module(debug parameter output command logs)
	stop {node|pruntime|phost}		use docker kill to stop module
	config					configure your phala node
	status					display the running status of all components
	update {clean}				update phala node
	logs {node|pruntime|phost}		show node module logs
	sgx-test				start the mining test program
EOF
exit 0
}

sgx_test()
{
	docker -v
	if [ $? -ne 0 ]; then
		log_err "----------docker not install----------"
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
			exit 1
		fi
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
