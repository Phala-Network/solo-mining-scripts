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
	elif [ ! -c /dev/sgx_enclave -a ! -c /dev/sgx_provision ]&&[ ! -c /dev/isgx ]; then
		log_err "----------dcap/isgx 驱动未安装，请执行sudo phala install dcap/sudo phala install isgx命令安装----------"
		exit 1
	elif [ -z "$node_name" ]||[ -z "$cores" ]||[ -z "$mnemonic" ]||[ -z "$pool_address" ]; then
		log_err "----------节点未配置，或重要启动配置丢失，请重新配置节点！----------"
		exit 1
	else
		cd $installdir
		docker-compose up -d
	fi
}
