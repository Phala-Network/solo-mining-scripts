#!/bin/bash

start_phala_node()
{
	log_info "---------Start phala-node----------"
	local node_name=$(cat $basedir/config.json | jq -r '.nodename')
	local ipaddr=$(cat $basedir/config.json | jq -r '.ipaddr')
	
	if [ ! -z $(docker ps -qf "name=phala-node") ]; then
		log_info "---------phala-node already exists----------"
		while true ; do
			local block_json=$(curl -sH "Content-Type: application/json" -d '{"id":1, "jsonrpc":"2.0", "method": "system_syncState", "params":[]}' http://$ipaddr:9933)
			local node_block=$(echo $block_json | jq -r '.result.currentBlock')
			local hightest_block=$(echo $block_json | jq -r '.result.highestBlock')
			if [ x"$node_block" == x"$hightest_block" ] && [ x"$hightest_block" > x"10" ]; then
				log_success "phala-node complete synchronously"
				break
			fi
			log_info "snycing $node_block of $hightest_block"
			sleep 30
		done
		exit 0
	fi

	docker run -ti --rm --name phala-node -d -e NODE_NAME=$node_name -p 9933:9933 -p 9944:9944 -p 30333:30333 -v $HOME/phala-node-data:/root/data swr.cn-east-3.myhuaweicloud.com/phala/phala-poc3-node
	if [ $? -ne 0 ]; then
		log_err "----------Start phala-node failed-------------"
		exit 1
	fi

	log_info "Wait for sync"
	sleep 30
	while true ; do
		local block_json=$(curl -sH "Content-Type: application/json" -d '{"id":1, "jsonrpc":"2.0", "method": "system_syncState", "params":[]}' http://$ipaddr:9933)
		local node_block=$(echo $block_json | jq -r '.result.currentBlock')
		local hightest_block=$(echo $block_json | jq -r '.result.highestBlock')
		if [ x"$node_block" == x"$hightest_block" ] && [ x"$hightest_block" > x"10" ]; then
			log_success "phala-node complete synchronously"
			break
		fi
		log_info "snycing $node_block of $hightest_block"
		sleep 30
	done
}

start_phala_node_debug()
{
    log_info "---------Start phala-node----------"
	local node_name=$(cat $basedir/config.json | jq -r '.nodename')
	local ipaddr=$(cat $basedir/config.json | jq -r '.ipaddr')
	
	if [ ! -z $(docker ps -qf "name=phala-node") ]; then
		log_info "---------phala-node already exists----------"
		while true ; do
			local block_json=$(curl -sH "Content-Type: application/json" -d '{"id":1, "jsonrpc":"2.0", "method": "system_syncState", "params":[]}' http://$ipaddr:9933)
			local node_block=$(echo $block_json | jq -r '.result.currentBlock')
			local hightest_block=$(echo $block_json | jq -r '.result.highestBlock')
			if [ x"$node_block" == x"$hightest_block" ] && [ x"$hightest_block" > x"10" ]; then
				log_success "phala-node complete synchronously"
				break
			fi
			log_info "snycing $node_block of $hightest_block"
			sleep 30
		done
		exit 0
	fi

	docker run -ti --rm --name phala-node -e NODE_NAME=$node_name -p 9933:9933 -p 9944:9944 -p 30333:30333 -v $HOME/phala-node-data:/root/data swr.cn-east-3.myhuaweicloud.com/phala/phala-poc3-node
	if [ $? -ne 0 ]; then
		log_err "----------Start phala-node failed-------------"
		exit 1
	fi

	log_info "Wait for sync"
	sleep 30
	while true ; do
		local block_json=$(curl -sH "Content-Type: application/json" -d '{"id":1, "jsonrpc":"2.0", "method": "system_syncState", "params":[]}' http://$ipaddr:9933)
		local node_block=$(echo $block_json | jq -r '.result.currentBlock')
		local hightest_block=$(echo $block_json | jq -r '.result.highestBlock')
		if [ x"$node_block" == x"$hightest_block" ] && [ x"$hightest_block" > x"10" ]; then
			log_success "phala-node complete synchronously"
			break
		fi
		log_info "snycing $node_block of $hightest_block"
		sleep 30
	done
}

start_phala_pruntime()
{
	log_info "----------Start phala-pruntime----------"
	if [ ! -z $(docker ps -qf "name=phala-pruntime") ]; then
		log_info "---------phala-pruntime already exists----------"
		exit 0
	fi
	
	local res_sgx=$(ls /dev | grep -w sgx)
	local res_isgx=$(ls /dev | grep -w isgx)
	if [ x"$res_sgx" == x"sgx" ] && [ x"$res_isgx" == x"" ]; then
		docker run -d -ti --rm --name phala-pruntime -p 8000:8000 -v $HOME/phala-pruntime-data:/root/data --device /dev/sgx/enclave --device /dev/sgx/provision phalanetwork/phala-poc3-pruntime
	elif [ x"$res_isgx" == x"isgx" ] && [ x"$res_sgx" == x"" ]; then
		docker run -d -ti --rm --name phala-pruntime -p 8000:8000 -v $HOME/phala-pruntime-data:/root/data --device /dev/isgx phalanetwork/phala-poc3-pruntime
	else
		log_err "----------sgx/dcap driver not install----------"
		exit 1
	fi

	if [ $? -ne 0 ]; then
		log_err "----------Start phala-pruntime failed----------"
		exit 1
	fi
}

start_phala_pruntime_debug()
{
	log_info "----------Start phala-pruntime----------"
	if [ ! -z $(docker ps -qf "name=phala-pruntime") ]; then
		log_info "---------phala-pruntime already exists----------"
		exit 0
	fi

	local res_sgx=$(ls /dev | grep -w sgx)
	local res_isgx=$(ls /dev | grep -w isgx)
	if [ x"$res_sgx" == x"sgx" ] && [ x"$res_isgx" == x"" ]; then
		docker run -ti --rm --name phala-pruntime -p 8000:8000 -v $HOME/phala-pruntime-data:/root/data --device /dev/sgx/enclave --device /dev/sgx/provision phalanetwork/phala-poc3-pruntime
	elif [ x"$res_isgx" == x"isgx" ] && [ x"$res_sgx" == x"" ]; then
		docker run -ti --rm --name phala-pruntime -p 8000:8000 -v $HOME/phala-pruntime-data:/root/data --device /dev/isgx phalanetwork/phala-poc3-pruntime
	else
		log_err "----------sgx/dcap driver not install----------"
		exit 1
	fi

	if [ $? -ne 0 ]; then
		log_err "----------Start phala-pruntime failed----------"
		exit 1
	fi
}

start_phala_phost()
{
	log_info "----------Start phala-phost----------"
	if [ ! -z $(docker ps -qf "name=phala-phost") ]; then
		log_info "---------phala-phost already exists----------"
		exit 0
	fi

	local ipaddr=$(cat $basedir/config.json | jq -r '.ipaddr')
	local mnemonic=$(cat $basedir/config.json | jq -r '.mnemonic')
	docker run -d -ti --rm --name phala-phost -e PRUNTIME_ENDPOINT="http://$ipaddr:8000" -e PHALA_NODE_WS_ENDPOINT="ws://$ipaddr:9944" -e MNEMONIC="$mnemonic" -e EXTRA_OPTS="-r" phalanetwork/phala-poc3-phost

	if [ $? -ne 0 ]; then
		log_err "----------Start phala-phost failed----------"
		exit 1
	fi
}

start_phala_phost_debug()
{
	log_info "----------Start phala-phost----------"
	if [ ! -z $(docker ps -qf "name=phala-phost") ]; then
		log_info "---------phala-phost already exists----------"
		exit 0
	fi

	local ipaddr=$(cat $basedir/config.json | jq -r '.ipaddr')
	local mnemonic=$(cat $basedir/config.json | jq -r '.mnemonic')
	docker run -ti --rm --name phala-phost -e PRUNTIME_ENDPOINT="http://$ipaddr:8000" -e PHALA_NODE_WS_ENDPOINT="ws://$ipaddr:9944" -e MNEMONIC="$mnemonic" -e EXTRA_OPTS="-r" phalanetwork/phala-poc3-phost

	if [ $? -ne 0 ]; then
		log_err "----------Start phala-phost failed----------"
		exit 1
	fi
}

start()
{
	if [ x"$2" == x"debug" ]; then
		case "$1" in
			node)
				start_phala_node_debug
				;;
			pruntime)
				start_phala_pruntime_debug
				;;
			phost)
				start_phala_phost_debug
				;;
			"")
				start_phala_node_debug
				start_phala_pruntime_debug
				sleep 30
				start_phala_phost_debug
				;;
			*)
				log_err "----------Parameter error----------"
				exit 1
        esac
	else
		case "$1" in
			node)
				start_phala_node
				;;
			pruntime)
				start_phala_pruntime
				;;
			phost)
				start_phala_phost
				;;
			"")
				config_set_all
				start_phala_node
				start_phala_pruntime
				sleep 30
				start_phala_phost
				;;
			*)
				log_err "----------Parameter error----------"
				exit 1
		esac
	fi
}
