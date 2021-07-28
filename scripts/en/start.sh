#!/bin/bash

start()
{
	local node_name=$(cat $installdir/.env | grep 'NODE_NAME' | awk -F "=" '{print $NF}')
	local cores=$(cat $installdir/.env | grep 'CORES' | awk -F "=" '{print $NF}')
	local mnemonic=$(cat $installdir/.env | grep 'MNEMONIC' | awk -F "=" '{print $NF}')
	local pool_address=$(cat $installdir/.env | grep 'OPERATOR' | awk -F "=" '{print $NF}')
	if ! type docker docker-compose node yq jq curl wget unzip zip >/dev/null 2>&1; then
		log_err "----------Lack of important dependent tools, please execute 'sudo phala install' to reinstall！----------"
		exit 1
	elif [ ! -c /dev/sgx_enclave -a ! -c /dev/sgx_provision ]&&[ ! -c /dev/isgx ]; then
		log_err "----------The dcap/isgx driver is not installed, please execute the 'sudo phala install dcap'/'sudo phala install isgx' command to install!----------"
		exit 1
	elif [ -z "$node_name" ]||[ -z "$cores" ]||[ -z "$mnemonic" ]||[ -z "$pool_address" ]; then
		log_err "----------The node is not configured, or the important configuration is lost, please reconfigure the node!----------"
		exit 1
	else
		cd $installdir
		docker-compose up -d
	fi
}
