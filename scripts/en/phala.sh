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

function phala_help()
{
cat << EOF
Usage:
	phala [OPTION]...

Options:
	help					display help information
	install					install your phala node
		<dcap>				install DCAP driver
		<isgx>				install isgx driver
	uninstall				uninstall your phala scripts
	start					start mining
		<khala>				start khala-node
	stop					stop mining
		<node>				stop phala-node container
		<pruntime>			stop phala-pruntime container
		<pherry>			stop phala-pherry container
		<bench>				stop phala-pruntime-bench container
	config					
		<show>				display all configuration of your node
		<set>				set all configuration
	status					display the running status of all components
	update					update all container,and don't clean up the container data
		<clean>				update all container,and clean up the container data
		<script>			update the script
	logs					print all container logs information
		<node>				print phala-node logs information
		<pruntime>			print phala-pruntime logs information
		<pherry>			print phala-pherry logs information
		<bench>				print phala-pruntime-bench logs information
	sgx-test				start the mining test program
	score-test				
		<Parameter>			get the scores of your machine
EOF
exit 0
}

function sgx_test()
{
	if ! type jq curl wget unzip zip docker docker-compose node yq dkms > /dev/null; then install_depenencies;fi
	if [ ! -L /dev/sgx/enclave ]&&[ ! -L /dev/sgx/provision ]&&[ ! -c /dev/sgx_enclave ]&&[ ! -c /dev/sgx_provision ]&&[ ! -c /dev/isgx ]; then install_driver;fi

	if [ -L /dev/sgx/enclave ]&&[ -L /dev/sgx/provision ]&&[ -c /dev/sgx_enclave ]&&[ -c /dev/sgx_provision ]&&[ ! -c /dev/isgx ]; then
		docker run -ti --rm --name phala-sgx_detect --device /dev/sgx/enclave --device /dev/sgx/provision --device /dev/sgx_enclave --device /dev/sgx_provision phalanetwork/phala-sgx_detect:latest
	elif [ ! -L /dev/sgx/enclave ]&&[ -L /dev/sgx/provision ]&&[ -c /dev/sgx_enclave ]&&[ -c /dev/sgx_provision ]&&[ ! -c /dev/isgx ]; then
		docker run -ti --rm --name phala-sgx_detect --device /dev/sgx/provision --device /dev/sgx_enclave --device /dev/sgx_provision phalanetwork/phala-sgx_detect:latest
	elif [ ! -L /dev/sgx/enclave ]&&[ ! -L /dev/sgx/provision ]&&[ -c /dev/sgx_enclave ]&&[ -c /dev/sgx_provision ]&&[ ! -c /dev/isgx ]; then
		docker run -ti --rm --name phala-sgx_detect --device /dev/sgx_enclave --device /dev/sgx_provision phalanetwork/phala-sgx_detect:latest
	elif [ ! -L /dev/sgx/enclave ]&&[ ! -L /dev/sgx/provision ]&&[ ! -c /dev/sgx_enclave ]&&[ -c /dev/sgx_provision ]&&[ ! -c /dev/isgx ]; then
		docker run -ti --rm --name phala-sgx_detect --device /dev/sgx_provision phalanetwork/phala-sgx_detect:latest
	elif [ ! -L /dev/sgx/enclave ]&&[ ! -L /dev/sgx/provision ]&&[ ! -c /dev/sgx_enclave ]&&[ ! -c /dev/sgx_provision ]&&[ -c /dev/isgx ]; then
		docker run -ti --rm --name phala-sgx_detect --device /dev/isgx phalanetwork/phala-sgx_detect:latest
	else
		log_info "----------The driver file was not found, please check the driver installation logs!----------"
		exit 1
	fi
}

function reportsystemlog()
{
	mkdir /tmp/systemlog
	ti=$(date +%s)
	dmidecode > /tmp/systemlog/system$ti.inf
	for container_name in phala-node phala-pruntime phala-pherry
	do
		if [ ! -z $(docker container ls -q -f "name=$container_name") ]; then
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

	if [ -L /dev/sgx/enclave ]&&[ -L /dev/sgx/provision ]&&[ -c /dev/sgx_enclave ]&&[ -c /dev/sgx_provision ]&&[ ! -c /dev/isgx ]; then
		docker run -dti --rm --name phala-sgx_detect --device /dev/sgx/enclave --device /dev/sgx/provision --device /dev/sgx_enclave --device /dev/sgx_provision phalanetwork/phala-sgx_detect > /tmp/systemlog/testdocker-dcap.inf
	elif [ ! -L /dev/sgx/enclave ]&&[ -L /dev/sgx/provision ]&&[ -c /dev/sgx_enclave ]&&[ -c /dev/sgx_provision ]&&[ ! -c /dev/isgx ]; then
		docker run -dti --rm --name phala-sgx_detect --device /dev/sgx/provision --device /dev/sgx_enclave --device /dev/sgx_provision phalanetwork/phala-sgx_detect > /tmp/systemlog/testdocker-dcap.inf
	elif [ ! -L /dev/sgx/enclave ]&&[ ! -L /dev/sgx/provision ]&&[ -c /dev/sgx_enclave ]&&[ -c /dev/sgx_provision ]&&[ ! -c /dev/isgx ]; then
		docker run -dti --rm --name phala-sgx_detect --device /dev/sgx_enclave --device /dev/sgx_provision phalanetwork/phala-sgx_detect > /tmp/systemlog/testdocker-dcap.inf
	elif [ ! -L /dev/sgx/enclave ]&&[ ! -L /dev/sgx/provision ]&&[ ! -c /dev/sgx_enclave ]&&[ -c /dev/sgx_provision ]&&[ ! -c /dev/isgx ]; then
		docker run -dti --rm --name phala-sgx_detect --device /dev/sgx_provision phalanetwork/phala-sgx_detect > /tmp/systemlog/testdocker-dcap.inf
	elif [ ! -L /dev/sgx/enclave ]&&[ ! -L /dev/sgx/provision ]&&[ ! -c /dev/sgx_enclave ]&&[ ! -c /dev/sgx_provision ]&&[ -c /dev/isgx ]; then
		docker run -dti --rm --name phala-sgx_detect --device /dev/isgx phalanetwork/phala-sgx_detect > /tmp/systemlog/testdocker-isgx.inf
	else
		log_info "----------The driver file was not found, please check the driver installation logs!----------"
		exit 1
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

function score_test()
{
	if [ $# != 1 ]; then
		log_err "---------The parameter of the number of machine cores is missing.----------"
		exit 1
	fi

	if ! type jq curl wget unzip zip docker docker-compose node yq dkms > /dev/null; then install_depenencies;fi
	if [ ! -L /dev/sgx/enclave ]&&[ ! -L /dev/sgx/provision ]&&[ ! -c /dev/sgx_enclave ]&&[ ! -c /dev/sgx_provision ]&&[ ! -c /dev/isgx ]; then install_driver;fi

	if [ ! -z $(docker container ls -q -f "name=phala-pruntime-bench") ]; then
		docker container rm --force phala-pruntime-bench
		docker image rm phalanetwork/phala-dev-pruntime-bench
		if [ -d /var/phala-pruntime-bench ]; then rm -rf /var/phala-pruntime-bench;fi
	fi

	if [ -L /dev/sgx/enclave ]&&[ -L /dev/sgx/provision ]&&[ -c /dev/sgx_enclave ]&&[ -c /dev/sgx_provision ]&&[ ! -c /dev/isgx ]; then
		docker run -dti --rm --name phala-pruntime-bench -p 8001:8000 -v /var/phala-pruntime-bench:/root/data -e EXTRA_OPTS="-c $1" --device /dev/sgx/enclave --device /dev/sgx/provision --device /dev/sgx_enclave --device /dev/sgx_provision phalanetwork/phala-dev-pruntime-bench
	elif [ ! -L /dev/sgx/enclave ]&&[ -L /dev/sgx/provision ]&&[ -c /dev/sgx_enclave ]&&[ -c /dev/sgx_provision ]&&[ ! -c /dev/isgx ]; then
		docker run -dti --rm --name phala-pruntime-bench -p 8001:8000 -v /var/phala-pruntime-bench:/root/data -e EXTRA_OPTS="-c $1" --device /dev/sgx/provision --device /dev/sgx_enclave --device /dev/sgx_provision phalanetwork/phala-dev-pruntime-bench
	elif [ ! -L /dev/sgx/enclave ]&&[ ! -L /dev/sgx/provision ]&&[ -c /dev/sgx_enclave ]&&[ -c /dev/sgx_provision ]&&[ ! -c /dev/isgx ]; then
		docker run -dti --rm --name phala-pruntime-bench -p 8001:8000 -v /var/phala-pruntime-bench:/root/data -e EXTRA_OPTS="-c $1" --device /dev/sgx_enclave --device /dev/sgx_provision phalanetwork/phala-dev-pruntime-bench
	elif [ ! -L /dev/sgx/enclave ]&&[ ! -L /dev/sgx/provision ]&&[ ! -c /dev/sgx_enclave ]&&[ -c /dev/sgx_provision ]&&[ ! -c /dev/isgx ]; then
		docker run -dti --rm --name phala-pruntime-bench -p 8001:8000 -v /var/phala-pruntime-bench:/root/data -e EXTRA_OPTS="-c $1" --device /dev/sgx_provision phalanetwork/phala-dev-pruntime-bench
	elif [ ! -L /dev/sgx/enclave ]&&[ ! -L /dev/sgx/provision ]&&[ ! -c /dev/sgx_enclave ]&&[ ! -c /dev/sgx_provision ]&&[ -c /dev/isgx ]; then
		docker run -dti --rm --name phala-pruntime-bench -p 8001:8000 -v /var/phala-pruntime-bench:/root/data -e EXTRA_OPTS="-c $1" --device /dev/isgx phalanetwork/phala-dev-pruntime-bench
	else
		log_info "----------The driver file was not found, please check the driver installation logs!----------"
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
		install $2
		;;
	config)
		config $2
		;;
	start)
		check_version
		start
		;;
	presync)
		local node_name
		while true ; do
			read -p "Enter your node name(not contain spaces): " node_name
			if [[ $node_name =~ \ |\' ]]; then
				printf "The node name cannot contain spaces, please re-enter!\n"
			else
				sed -i "7c NODE_NAME=$node_name" $installdir/.env
				break
			fi
		done
		cd $installdir
		docker-compose up -d
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
		logs $2
		;;
	uninstall)
		uninstall
		;;
	score-test)
		score_test $2
		;;
	sgx-test)
		sgx_test
		;;
	*)
		phala_help
		;;
esac

exit 0
