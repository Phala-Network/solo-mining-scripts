#!/bin/bash

function start()
{
	if [ ! -L /dev/sgx/enclave ]&&[ ! -L /dev/sgx/provision ]&&[ ! -c /dev/sgx_enclave ]&&[ ! -c /dev/sgx_provision ]&&[ ! -c /dev/isgx ]; then
		install
	elif ! type jq curl wget unzip zip docker docker-compose node yq dkms > /dev/null; then
		install_depenencies
	fi

	local node_name=$(cat $installdir/.env | grep 'NODE_NAME' | awk -F "=" '{print $NF}')
	local cores=$(cat $installdir/.env | grep 'CORES' | awk -F "=" '{print $NF}')
	local mnemonic=$(cat $installdir/.env | grep 'MNEMONIC' | awk -F "=" '{print $NF}')
	local pool_address=$(cat $installdir/.env | grep 'OPERATOR' | awk -F "=" '{print $NF}')
	if [ -z "$node_name" ]||[ -z "$cores" ]||[ -z "$mnemonic" ]||[ -z "$pool_address" ]; then
		log_err "----------The node is not configured, start configuring the node!----------"
		config set
	fi
	cd $installdir
	docker-compose up -d
}
