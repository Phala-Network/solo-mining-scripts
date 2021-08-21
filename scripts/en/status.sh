#!/bin/bash

function status()
{
	trap "clear;exit" 2
	while true; do
		local node_status="stop"
		local pruntime_status="stop"
		local pherry_status="stop"
		local node_name=$(cat $installdir/.env | grep 'NODE_NAME' | awk -F "=" '{print $NF}')
		local cores=$(cat $installdir/.env | grep 'CORES' | awk -F "=" '{print $NF}')
		local mnemonic=$(cat $installdir/.env | grep 'MNEMONIC' | awk -F "=" '{print $NF}')
		local gas_address=$(cat $installdir/.env | grep 'GAS_ACCOUNT_ADDRESS' | awk -F "=" '{print $NF}')
		local pool_address=$(cat $installdir/.env | grep 'OPERATOR' | awk -F "=" '{print $NF}')
		local balance=$(node $installdir/console.js free-balance $gas_address 2>&1)
		balance=$(echo $balance | awk -F " " '{print $NF}')
		balance=$(echo "$balance / 1000000000000"|bc)
		local node_block=$(curl -sH "Content-Type: application/json" -d '{"id":1, "jsonrpc":"2.0", "method": "system_syncState", "params":[]}' http://0.0.0.0:9933 | jq '.result.currentBlock')
		local publickey=$(curl -X POST -sH "Content-Type: application/json" -d '{"input": {}, "nonce": {}}' http://0.0.0.0:8000/get_info | jq '.payload|fromjson.public_key' | sed 's/\"//g' | sed 's/^/0x/')

		check_docker_status phala-node
		local res=$?
		if [ $res -eq 0 ]; then
			node_status="running"
		elif [ $res -eq 2 ]; then
			node_status="exited"
		fi

		check_docker_status phala-pruntime
		local res=$?
		if [ $res -eq 0 ]; then
			pruntime_status="running"
		elif [ $res -eq 2 ]; then
			pruntime_status="exited"
		fi

		check_docker_status phala-pherry
		local res=$?
		if [ $res -eq 0 ]; then
			pherry_status="running"
		elif [ $res -eq 2 ]; then
			pherry_status="exited"
		fi

		clear
		if [ $(echo "$balance < 2"|bc) -eq 1 ]; then
			printf "
--------------------------------------------------------------------------
	Service		Status		CurrentBlock
--------------------------------------------------------------------------
	phala-node	${node_status}		${node_block}
	phala-pruntime  ${pruntime_status}
	phala-pherry    ${pherry_status}
--------------------------------------------------------------------------
	Account information	contents
--------------------------------------------------------------------------
	node name           	${node_name}
	mining core     	${cores}
	GAS account address     ${gas_address}
	GAS account balance     \E[1;32m${balance}\E[0m \E[41;33mWaring!\E[0m
	pool account address    ${pool_address}
	Worker-public-key	${publickey}
--------------------------------------------------------------------------
"
		else
			printf "
--------------------------------------------------------------------------
	Service		Status		CurrentBlock
--------------------------------------------------------------------------
	phala-node	${node_status}		${node_block}
	phala-pruntime  ${pruntime_status}
	phala-pherry    ${pherry_status}
--------------------------------------------------------------------------
	Account information	contents
--------------------------------------------------------------------------
	node name           	${node_name}
	mining core     	${cores}
	GAS account address     ${gas_address}
	GAS account balance     \E[1;32m${balance}\E[0m
	pool account address    ${pool_address}
	Worker-public-key	${publickey}
--------------------------------------------------------------------------
"
		fi
		sleep 60
	done
}
