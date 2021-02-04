#!/bin/bash

start_phala_node()
{
	log_info "---------启动 phala node----------"
	local node_name=$(cat $basedir/config.json | jq -r '.nodename')
	if [ x"$1" == x"debug" ]; then
		docker run -ti --rm --name phala-node -e NODE_NAME=$node_name -p 9933:9933 -p 9944:9944 -p 30333:30333 -v $HOME/phala-node-data:/root/data phalanetwork/phala-poc3-node
	else
		docker run -ti --rm --name phala-node -d -e NODE_NAME=$node_name -p 9933:9933 -p 9944:9944 -p 30333:30333 -v $HOME/phala-node-data:/root/data phalanetwork/phala-poc3-node
	fi

	if [ $? -ne 0 ]; then
		log_err "----------启动 phala node 失败-------------"
		exit 1
	fi

	log_info "等待node节点同步区块高度"
	sleep 30
	while true ; do
		local ipaddr=$(cat $basedir/config.json | jq -r '.ipaddr')
		local block_json=$(curl -sH "Content-Type: application/json" -d '{"id":1, "jsonrpc":"2.0", "method": "system_syncState", "params":[]}' http://$ipaddr:9933)
		local node_block=$(echo $block_json | jq -r '.result.currentBlock')
		local hightest_block=$(echo $block_json | jq -r '.result.highestBlock')
		if [ x"$node_block" == x"$hightest_block" ] && [ x"$hightest_block" > x"10" ]; then
			log_success "phala-node 同步完成"
			break
		fi
		log_info "同步进度： 节点高度（$node_block），网络高度（$hightest_block）"
		sleep 30
	done
}

start_phala_pruntime()
{
	log_info "----------启动pruntime----------"
	
	res=$(ls /dev | grep sgx)
	if [ x"$res" == x"sgx" ]; then
		if [ x"$1" == x"debug" ]; then
			docker run -ti --rm --name phala-pruntime -p 8000:8000 -v $HOME/phala-pruntime-data:/root/data --device /dev/sgx/enclave --device /dev/sgx/provision phalanetwork/phala-poc3-pruntime
		else
			docker run -d -ti --rm --name phala-pruntime -p 8000:8000 -v $HOME/phala-pruntime-data:/root/data --device /dev/sgx/enclave --device /dev/sgx/provision phalanetwork/phala-poc3-pruntime
		fi
	else
		if [ x"$1" == x"debug" ]; then
			docker run -ti --rm --name phala-pruntime -p 8000:8000 -v $HOME/phala-pruntime-data:/root/data --device /dev/isgx phalanetwork/phala-poc3-pruntime
		else
			docker run -d -ti --rm --name phala-pruntime -p 8000:8000 -v $HOME/phala-pruntime-data:/root/data --device /dev/isgx phalanetwork/phala-poc3-pruntime
		fi
	fi

	if [ $? -ne 0 ]; then
		log_err "----------启动pruntime失败----------"
		exit 1
	fi
}

start_phala_phost()
{
	log_info "----------启动phost----------"
	local ipaddr=$(cat $basedir/config.json | jq -r '.ipaddr')
	local mnemonic=$(cat $basedir/config.json | jq -r '.mnemonic')
	if [ x"$1" == x"debug" ]; then
		docker run -ti --rm --name phala-phost -e PRUNTIME_ENDPOINT="http://$ipaddr:8000" -e PHALA_NODE_WS_ENDPOINT="ws://$ipaddr:9944" -e MNEMONIC="$mnemonic" -e EXTRA_OPTS="-r" phalanetwork/phala-poc3-phost
	else
		docker run -d -ti --rm --name phala-phost -e PRUNTIME_ENDPOINT="http://$ipaddr:8000" -e PHALA_NODE_WS_ENDPOINT="ws://$ipaddr:9944" -e MNEMONIC="$mnemonic" -e EXTRA_OPTS="-r" phalanetwork/phala-poc3-phost
	fi

	if [ $? -ne 0 ]; then
		log_err "----------启动phost失败----------"
		exit 1
	fi
}

start()
{
	if [ x"$2" == x"debug" ]; then
		case "$1" in
			"")
				start_phala_node debug
				start_phala_pruntime debug
				sleep 30
				start_phala_phost debug
				;;
			node)
				start_phala_node debug
				;;
			pruntime)
				start_phala_pruntime debug
				;;
			phost)
				start_phala_phost debug
				;;
			*)
				log_err "----------参数错误----------"
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
				start_phala_node
				start_phala_pruntime
				sleep 30
				start_phala_phost
				;;
			*)
				log_err "----------参数错误----------"
				exit 1
		esac
	fi
}
