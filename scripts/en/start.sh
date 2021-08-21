#!/bin/bash

function start()
{
	local node_name=$(cat $installdir/.env | grep 'NODE_NAME' | awk -F "=" '{print $NF}')
	local cores=$(cat $installdir/.env | grep 'CORES' | awk -F "=" '{print $NF}')
	local mnemonic=$(cat $installdir/.env | grep 'MNEMONIC' | awk -F "=" '{print $NF}')
	local pool_address=$(cat $installdir/.env | grep 'OPERATOR' | awk -F "=" '{print $NF}')
	if ! type docker docker-compose node yq jq curl wget unzip zip >/dev/null 2>&1; then
		log_err "----------Lack of important dependent tools, please execute 'sudo phala install' to reinstall！----------"
		exit 1
	fi

	if [ ! -c /dev/sgx_enclave -a ! -c /dev/sgx_provision ]&&[ ! -c /dev/isgx ]; then
		log_err "----------The dcap/isgx driver is not installed, please execute the 'sudo phala install dcap'/'sudo phala install isgx' command to install!----------"
		exit 1
	fi

	if [ -z "$node_name" ]||[ -z "$cores" ]||[ -z "$mnemonic" ]||[ -z "$pool_address" ]; then
		log_err "----------The node is not configured, or the important configuration is lost, start configuring the node!----------"
		phala config set
	fi
	cd $installdir
	docker-compose up -d
	docker run -dti --rm --name khala-node -e NODE_NAME=$node_name -e NODE_ROLE=MINER -p 40333:30333 -p 40334:30334 -v /var/khala-dev-node:/root/data phalanetwork/khala-node
}