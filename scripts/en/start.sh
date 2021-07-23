#!/bin/bash

start_phala_node()
{
	log_info "---------Start phala-node----------"
	local node_name=$(cat $installdir/config.json | jq -r '.nodename')
	local ipaddr=$(cat $installdir/config.json | jq -r '.ipaddr')
	if [ -z $node_name ] || [ -z $ipaddr ]; then
		config_set_all
		local node_name=$(cat $installdir/config.json | jq -r '.nodename')
		local ipaddr=$(cat $installdir/config.json | jq -r '.ipaddr')
	fi
        log_info "your node name:$node_name"
        log_info "your IP address:$ipaddr"

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

	docker run -dti --rm --name phala-node -e NODE_NAME=$node_name -p 9933:9933 -p 9944:9944 -p 30333:30333 -v $HOME/phala-node-data:/root/data phalanetwork/phala-poc4-node
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
	local node_name=$(cat $installdir/config.json | jq -r '.nodename')
	local ipaddr=$(cat $installdir/config.json | jq -r '.ipaddr')
	if [ -z $node_name ] || [ -z $ipaddr ]; then
		config_set_all
		local node_name=$(cat $installdir/config.json | jq -r '.nodename')
		local ipaddr=$(cat $installdir/config.json | jq -r '.ipaddr')
	fi
        log_info "your node name:$node_name"
        log_info "your IP address:$ipaddr"

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

	docker run -ti --rm --name phala-node -e NODE_NAME=$node_name -p 9933:9933 -p 9944:9944 -p 30333:30333 -v $HOME/phala-node-data:/root/data phalanetwork/phala-poc4-node
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
		docker run -d -ti --rm --name phala-pruntime -p 8000:8000 -v $HOME/phala-pruntime-data:/root/data --device /dev/sgx/enclave --device /dev/sgx/provision phalanetwork/phala-poc4-pruntime
	elif [ x"$res_isgx" == x"isgx" ] && [ x"$res_sgx" == x"" ]; then
		docker run -d -ti --rm --name phala-pruntime -p 8000:8000 -v $HOME/phala-pruntime-data:/root/data --device /dev/isgx phalanetwork/phala-poc4-pruntime
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
		docker run -ti --rm --name phala-pruntime -p 8000:8000 -v $HOME/phala-pruntime-data:/root/data --device /dev/sgx/enclave --device /dev/sgx/provision phalanetwork/phala-poc4-pruntime
	elif [ x"$res_isgx" == x"isgx" ] && [ x"$res_sgx" == x"" ]; then
		docker run -ti --rm --name phala-pruntime -p 8000:8000 -v $HOME/phala-pruntime-data:/root/data --device /dev/isgx phalanetwork/phala-poc4-pruntime
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

	local ipaddr=$(cat $installdir/config.json | jq -r '.ipaddr')
	local mnemonic=$(cat $installdir/config.json | jq -r '.mnemonic')
	if [ -z $ipaddr ] || [ -z "$mnemonic" ]; then
		config_set_all
		local ipaddr=$(cat $installdir/config.json | jq -r '.ipaddr')
		local mnemonic=$(cat $installdir/config.json | jq -r '.mnemonic')
	fi
	
	docker run -d -ti --rm --name phala-phost -e PRUNTIME_ENDPOINT="http://$ipaddr:8000" -e PHALA_NODE_WS_ENDPOINT="ws://$ipaddr:9944" -e MNEMONIC="$mnemonic" -e EXTRA_OPTS="-r" phalanetwork/phala-poc4-phost
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

	local ipaddr=$(cat $installdir/config.json | jq -r '.ipaddr')
	local mnemonic=$(cat $installdir/config.json | jq -r '.mnemonic')
	if [ -z $ipaddr ] || [ -z "$mnemonic" ]; then
		config_set_all
		local ipaddr=$(cat $installdir/config.json | jq -r '.ipaddr')
		local mnemonic=$(cat $installdir/config.json | jq -r '.mnemonic')
	fi
	docker run -ti --rm --name phala-phost -e PRUNTIME_ENDPOINT="http://$ipaddr:8000" -e PHALA_NODE_WS_ENDPOINT="ws://$ipaddr:9944" -e MNEMONIC="$mnemonic" -e EXTRA_OPTS="-r" phalanetwork/phala-poc4-phost

	if [ $? -ne 0 ]; then
		log_err "----------Start phala-phost failed----------"
		exit 1
	fi
}

start()
{
	local node_name=$(cat $installdir/.env | grep 'NODE_NAME' | awk -F "=" '{print $NF}')
	local cores=$(cat $installdir/.env | grep 'CORES' | awk -F "=" '{print $NF}')
	local mnemonic=$(cat $installdir/.env | grep 'MNEMONIC' | awk -F "=" '{print $NF}')
	local pool_address=$(cat $installdir/.env | grep 'OPERATOR' | awk -F "=" '{print $NF}')
	local res_isgx=$(ls /dev | grep isgx)
	local res_sgx=$(ls /dev | grep sgx)
	local res=0
	docker -v
	res=$(($?|$res))
	docker-compose -v
	res=$(($?|$res))
	node -v
	res=$(($?|$res))
	if [ $res -ne 0 ]; then
		log_err "----------Lack of important dependent tools, please execute 'sudo phala install' to reinstall！----------"
		exit 1
	elif [ -z $node_name ]||[ -z $cores ]||[ -z $mnemonic ]||[ -z $pool_address ]; then
		log_err "----------The node is not configured, or the important configuration is lost, please reconfigure the node!----------"
		exit 1
	elif [ -z $res_sgx ]&&[ -z $res_isgx ]; then
		log_err "----------The dcap/isgx driver is not installed, please execute the 'sudo phala install dcap'/'sudo phala install isgx' command to install!----------"
		exit 1
	else
		cd $installdir
		docker-compose up -d
	fi
}
