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

	local res_sgx=$(ls /dev | grep -w sgx)
	local res_isgx=$(ls /dev | grep -w isgx)
	if [ x"$res_sgx" == x"sgx" ] && [ x"$res_isgx" == x"" ]; then
		docker run -ti --rm --name phala-sgx_detect --device /dev/sgx/enclave --device /dev/sgx/provision phalanetwork/phala-sgx_detect
	elif [ x"$res_isgx" == x"isgx" ]; then
		docker run -ti --rm --name phala-sgx_detect --device /dev/isgx phalanetwork/phala-sgx_detect
	else
		log_err "----------sgx/dcap driver not install----------"
		exit 1
	fi
}

score_test()
{
	if [ $# != 1 ]; then
		log_err "---------Parameter error----------"
		exit 1
	fi

	docker -v
	if [ $? -ne 0 ]; then
		log_err "----------docker not install----------" 
		install_depenencies
	fi

	local res_sgx=$(ls /dev | grep -w sgx)
	local res_isgx=$(ls /dev | grep -w isgx)
	if [ x"$res_sgx" == x"sgx" ] && [ x"$res_isgx" == x"" ] && [ -z $(docker ps -qf "name=phala-pruntime-bench") ]; then
		docker run -dti --rm --name phala-pruntime-bench -p 8001:8000 -v $HOME/data/phala-pruntime-data:/root/data -e EXTRA_OPTS="-c $1" --device /dev/sgx/enclave --device /dev/sgx/provision phalanetwork/phala-dev-pruntime-bench
	elif [ x"$res_isgx" == x"isgx" ] && [ -z $(docker ps -qf "name=phala-pruntime-bench") ]; then
		docker run -dti --rm --name phala-pruntime-bench -p 8001:8000 -v $HOME/data/phala-pruntime-data:/root/data -e EXTRA_OPTS="-c $1" --device /dev/isgx phalanetwork/phala-dev-pruntime-bench
	elif [ x"$res_sgx" == x"" ] && [ x"$res_isgx" == x"" ]; then
		log_err "----------sgx/dcap driver not install----------"
		exit 1
	fi

	echo -e "\033[31m Affected by various environmental factors, the performance score may fluctuate to a certain extent! \
	This rating is a preview version, and there may be changes in the preparation of the mainnet line! \033[0m"
	echo "The rating is being updated, please wait a moment!"
	sleep 30
	while true; do
		sleep 30
		score=$(curl -d '{"input": {}, "nonce": {}}' -H "Content-Type: application/json"  http://localhost:8001/get_info 2>/dev/null | jq -r .payload | jq .score)
		printf "\rThe score of your machine is: %d" $score
	done
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
	score_test)
		score_test $2
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
