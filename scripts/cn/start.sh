#!/bin/bash

start()
{
	local node_name=$(cat $installdir/.env | grep 'NODE_NAME' | awk -F "=" '{print $NF}')
	local cores=$(cat $installdir/.env | grep 'CORES' | awk -F "=" '{print $NF}')
	local mnemonic=$(cat $installdir/.env | grep 'MNEMONIC' | awk -F "=" '{print $NF}')
	local pool_address=$(cat $installdir/.env | grep 'OPERATOR' | awk -F "=" '{print $NF}')

	if ! type jq curl wget unzip zip docker docker-compose node yq dkms bc > /dev/null 2>&1; then install_depenencies;fi
	if [ ! -L /dev/sgx/enclave ]&&[ ! -L /dev/sgx/provision ]&&[ ! -c /dev/sgx_enclave ]&&[ ! -c /dev/sgx_provision ]&&[ ! -c /dev/isgx ]; then install_driver;fi

	if [ -z "$node_name" ]||[ -z "$cores" ]||[ -z "$mnemonic" ]||[ -z "$pool_address" ]; then
		log_err "----------节点未配置，开始配置节点！----------"
		config set
	fi
	cd $installdir
	docker-compose up -d
	docker run -dti --rm --name khala-node -e NODE_NAME=$node_name -e NODE_ROLE=MINER -p 40333:30333 -p 40334:30334 -v /var/khala-dev-node:/root/data phalanetwork/khala-node
}
