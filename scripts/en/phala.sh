#!/bin/bash

installdir=/opt/phala
scriptdir=$installdir/scripts

source $scriptdir/utils.sh
source $scriptdir/config.sh
source $scriptdir/install_phala.sh
source $scriptdir/logs.sh
source $scriptdir/start.sh
source $scriptdir/status.sh
source $scriptdir/stop.sh
source $scriptdir/uninstall.sh
source $scriptdir/update.sh

help()
{
cat << EOF
Usage:
	help					show help information
	install {init|isgx|dcap}		install your phala node
	uninstall               		uninstall your phala scripts
	start {node|pruntime|pherry}{debug}	start your node module(debug parameter output command logs)
	stop {node|pruntime|pherry}		use docker kill to stop module
	config					configure your phala node
	status					display the running status of all components
	update {clean}				update phala node
	logs {node|pruntime|pherry}		show node module logs
	sgx-test				start the mining test program
	score-test				get the scores of your machine
EOF
exit 0
}

sgx_test()
{
	if ! type docker > /dev/null 2>&1; then
		log_err "----------docker not install----------"
		install_depenencies
	fi

	if [ ! -L /dev/sgx/enclave -a ! -L /dev/sgx/provision -a ! -c /dev/sgx_enclave -a ! -c /dev/sgx_provision -a ! -c /dev/isgx ]; then
		install
	fi

	if [ -L /dev/sgx/enclave -a -L /dev/sgx/provision -a -c /dev/sgx_enclave -a -c /dev/sgx_provision -a ! -c /dev/isgx ]; then
		docker run -ti --rm --name phala-sgx_detect --device /dev/sgx_enclave --device /dev/sgx_provision --device /dev/sgx/enclave --device /dev/sgx/provision swr.cn-east-3.myhuaweicloud.com/phala/phala-sgx_detect:latest
	elif [ ! -L /dev/sgx/enclave -a ! -L /dev/sgx/provision -a -c /dev/sgx_enclave -a -c /dev/sgx_provision -a ! -c /dev/isgx ]; then
		docker run -ti --rm --name phala-sgx_detect --device /dev/sgx_enclave --device /dev/sgx_provision swr.cn-east-3.myhuaweicloud.com/phala/phala-sgx_detect:latest
	elif [ ! -L /dev/sgx/enclave -a ! -L /dev/sgx/provision -a ! -c /dev/sgx_enclave -a ! -c /dev/sgx_provision -a -c /dev/isgx ]; then
		docker run -ti --rm --name phala-sgx_detect --device /dev/isgx swr.cn-east-3.myhuaweicloud.com/phala/phala-sgx_detect:latest
	else
		log_err "----------sgx/dcap driver not install----------"
		exit 1
	fi
}

reportsystemlog()
{
	mkdir /tmp/systemlog
	ti=$(date +%s)
	dmidecode > /tmp/systemlog/system$ti.inf
	for container_name in phala-node phala-pruntime phala-pherry
	do
		if [ ! -z $(docker ps -qf "name=$container_name") ]; then
			case $container_name in
				phala-node)
					docker logs phala-node --tail 50000 > /tmp/systemlog/node$ti.inf
					;;
				phala-pruntime)
					docker logs phala-pruntime --tail 50000 > /tmp/systemlog/pruntime$ti.inf
					;;
				phala-pherry)
					docker logs phala-pherry --tail 50000 > /tmp/systemlog/pherry$ti.inf
					;;
				*)
					break
			esac
		fi
	done

	if [ -c /dev/sgx_enclave -a -c /dev/sgx_provision -a ! -c /dev/isgx ]; then
		docker run -ti --rm --name phala-sgx_detect --device /dev/sgx_enclave --device /dev/sgx_provision phalanetwork/phala-sgx_detect > /tmp/systemlog/testdocker-dcap.inf
	elif [ ! -c /dev/sgx_enclave -a ! -c /dev/sgx_provision -a -c /dev/isgx ]; then
		docker run -ti --rm --name phala-sgx_detect --device /dev/isgx phalanetwork/phala-sgx_detect > /tmp/systemlog/testdocker-isgx.inf
	fi
	echo "$1 $score" > /tmp/systemlog/score$ti.inf
	zip -r /tmp/systemlog$ti.zip /tmp/systemlog/*
	fln="file=@/tmp/systemlog"$ti".zip"
	echo $fln
	sleep 10
	curl -F $fln http://118.24.253.211:10128/upload?token=1145141919
	rm /tmp/systemlog$ti.zip
	rm -r /tmp/systemlog
}

score_test()
{
	if [ $# != 1 ]; then
		log_err "---------The parameter of the number of machine cores is missing.----------"
		exit 1
	fi

	if ! type docker > /dev/null 2>&1; then
		log_err "----------docker not install----------" 
		install_depenencies
	fi

	if [ ! -z $(docker ps -qf "name=phala-pruntime-bench") ]; then
		docker container stop phala-pruntime-bench
		docker image rm swr.cn-east-3.myhuaweicloud.com/phala/phala-dev-pruntime-bench
		rm -rf /var/phala-pruntime-bench
	fi

	if [ -L /dev/sgx/enclave -a -L /dev/sgx/provision -a -c /dev/sgx_enclave -a -c /dev/sgx_provision -a ! -c /dev/isgx ]; then
		docker run -dti --rm --name phala-pruntime-bench -p 8001:8000 -v /var/phala-pruntime-bench:/root/data -e EXTRA_OPTS="-c $1" --device /dev/sgx_enclave --device /dev/sgx_provision --device /dev/sgx/enclave --device /dev/sgx/provision phalanetwork/phala-dev-pruntime-bench
	elif [ ! -L /dev/sgx/enclave -a ! -L /dev/sgx/provision -a -c /dev/sgx_enclave -a -c /dev/sgx_provision -a ! -c /dev/isgx ]; then
		docker run -dti --rm --name phala-pruntime-bench -p 8001:8000 -v /var/phala-pruntime-bench:/root/data -e EXTRA_OPTS="-c $1" --device /dev/sgx_enclave --device /dev/sgx_provision phalanetwork/phala-dev-pruntime-bench
	elif [ ! -L /dev/sgx/enclave -a ! -L /dev/sgx/provision -a ! -c /dev/sgx_enclave -a ! -c /dev/sgx_provision -a -c /dev/isgx ]; then
		docker run -dti --rm --name phala-pruntime-bench -p 8001:8000 -v /var/data/phala-pruntime-bench:/root/data -e EXTRA_OPTS="-c $1" --device /dev/isgx swr.cn-east-3.myhuaweicloud.com/phala/phala-dev-pruntime-bench
	else
		log_err "----------sgx/dcap driver not install----------"
		exit 1
	fi

	echo -e "\033[31m The performance score could be influnced by various factors, including the CPU tempreture, power supply, and the background processes in your system. So it may fluctuate at the beginning, but it will be stablized after running for a while.\n The benchmark algorithm is still experimental and may be subject to future changes. \033[0m"
	echo "The rating is being updated, please wait a moment!"
	sleep 90
	score=$(curl -d '{"input": {}, "nonce": {}}' -H "Content-Type: application/json"  http://localhost:8001/get_info 2>/dev/null | jq -r .payload | jq .score)
	printf "\rThe score of your machine is: %d" $score
	if read -t 10 -p "Would you like to upload your score to PhalaNetwork (automatically upload after 10 seconds by default)? [Y/n] " input; then
		case $input in
			[yY][eE][sS]|[yY])
				reportsystemlog $1
				log_info "----------Upload success！----------"
				;;
			[nN][oO]|[nN])
				log_info "----------Cancel upload！----------"
				;;
		esac
	else
		reportsystemlog $1
	fi
}

if [ $(id -u) -ne 0 ]; then
	echo "Please run with sudo!"
	exit 1
fi

case "$1" in
	install)
		check_version
		install $2
		;;
	config)
		config $2
		;;
	start)
		start
		;;
	stop)
		stop $2
		;;
	status)
		status $2
		;;
	update)
		update $2
		;;
	logs)
		logs
		;;
	uninstall)
		uninstall
		;;
	score-test)
		check_version
		score_test $2
		;;
	sgx-test)
		sgx_test
		;;
	*)
		help
		;;
esac

exit 0
