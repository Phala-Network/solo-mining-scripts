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
		log_err "----------节点未配置，开始配置节点！----------"
		config set
	fi
	case $1 in
		"")
			cd $installdir
			docker-compose up -d
			;;
		khala)
			if [ -z $(docker container ls -q -f "name=khala-node") ]; then
				docker container rm --force $(docker container ls -q -f "name=khala-node")
				docker image rm phalanetwork/khala-node
				rm -rf /var/khala-dev-node
			fi
			docker run -dti --rm --name khala-node -e NODE_NAME=$node_name -e NODE_ROLE=MINER -p 40333:30333 -p 40334:30334 -v /var/khala-dev-node:/root/data phalanetwork/khala-node
			;;
	esac
}
