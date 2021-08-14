#!/bin/bash

start()
{
	local node_name=$(cat $installdir/.env | grep 'NODE_NAME' | awk -F "=" '{print $NF}')
	local cores=$(cat $installdir/.env | grep 'CORES' | awk -F "=" '{print $NF}')
	local mnemonic=$(cat $installdir/.env | grep 'MNEMONIC' | awk -F "=" '{print $NF}')
	local pool_address=$(cat $installdir/.env | grep 'OPERATOR' | awk -F "=" '{print $NF}')
	if ! type docker docker-compose node yq jq curl wget unzip zip >/dev/null 2>&1; then
		log_err "----------缺少重要依赖工具，请执行sudo phala install重新安装！----------"
		exit 1
	fi

	if [ ! -c /dev/sgx_enclave -a ! -c /dev/sgx_provision ]&&[ ! -c /dev/isgx ]; then
		log_err "----------dcap/isgx 驱动未安装，请执行sudo phala install dcap/sudo phala install isgx命令安装----------"
		exit 1
	fi

	if [ -z "$node_name" ]||[ -z "$cores" ]||[ -z "$mnemonic" ]||[ -z "$pool_address" ]; then
		log_err "----------节点未配置，开始配置节点！----------"
		config_set_all
	fi
	cd $installdir
	docker-compose up -d
	docker run -dti --rm --name khala-node -e NODE_NAME=$node_name -e NODE_ROLE=MINER -P 40333:30333 -P 40334:30334 -v /var/khala-dev-node:/root/data phalanetwork/khala-node
}
