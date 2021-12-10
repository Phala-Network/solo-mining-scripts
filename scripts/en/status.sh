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
		local script_version=$(cat $installdir/.env | grep 'version' | awk -F "=" '{print $NF}')
		local balance=$(node $installdir/scripts/console.js --substrate-ws-endpoint "wss://khala.api.onfinality.io/public-ws" chain free-balance $gas_address 2>&1)
		balance=$(echo $balance | awk -F " " '{print $NF}')
		balance=$(echo "$balance / 1000000000000"|bc)
		local khala_head_block=$(node $installdir/scripts/console.js --substrate-ws-endpoint "wss://khala.api.onfinality.io/public-ws" chain sync-state 2>/dev/null)
		khala_head_block=$(echo $khala_head_block | awk -F "," '{print $5}' | sed 's/ currentBlock: //g')
		local khala_node_block=$(curl -sH "Content-Type: application/json" -d '{"id":1, "jsonrpc":"2.0", "method": "system_syncState", "params":[]}' http://0.0.0.0:9933 | jq '.result.currentBlock')
		local kusama_head_block=$(node $installdir/scripts/console.js --substrate-ws-endpoint "wss://pub.elara.patract.io/kusama" chain sync-state | awk -F " " '/currentBlock/ {print $NF}' | sed 's/,//g')
		local kusama_node_block=$(curl -sH "Content-Type: application/json" -d '{"id":1, "jsonrpc":"2.0", "method": "system_syncState", "params":[]}' http://0.0.0.0:9934 | jq '.result.currentBlock')
		local get_info=$(curl -X POST -sH "Content-Type: application/json" -d '{"input": {}, "nonce": {}}' http://0.0.0.0:8000/get_info)
		local publickey=$(echo $get_info | jq '.payload|fromjson.public_key' | sed 's/\"//g' | sed 's/^/0x/')
		local registered=$(echo $get_info | jq '.payload|fromjson.registered' | sed 's/\"//g')
		local blocknum=$(echo $get_info | jq '.payload|fromjson.blocknum' | sed 's/\"//g')
		local headernum=$(echo $get_info | jq '.payload|fromjson.headernum' | sed 's/\"//g')
		local score=$(echo $get_info | jq '.payload|fromjson.score' | sed 's/\"//g')

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

		SYNCED="Synchronization completed"
		SYNCING="Synchronizing, please wait"

		blockInfo=(${khala_node_block} ${khala_head_block} ${kusama_node_block} ${kusama_head_block} ${blocknum} ${headernum})
		compareOrder1=(1 3 0 2)
		compareOrder2=(0 2 4 5)

		for i in `seq 0 3`; do
			compare[${i}]=$(echo "${blockInfo[${compareOrder1[${i}]}]} - ${blockInfo[${compareOrder2[${i}]}]}")
			diff[${i}]=$(echo ${compare[${i}]} | bc)
			if [[ ${diff[${i}]} -lt 2 ]]; then
				sync_status[${i}]=${SYNCED}
			else
				sync_status[${i}]=${SYNCING}
			fi
		done

		if [ ${registered} = "true" ]; then
			registerStatus="Registered, you can use the miner’s public key to add a miner"
		else
			registerStatus="Not registered, please wait for the synchronization to complete"
			publickey="Waiting for the miner to register"
		fi

		if [ $(echo "$balance < 2"|bc) -eq 1 ]; then
			gas_balance=$(echo '\E[1;33m'${balance}'\E[0m'"PHA"'\E[41;33m'" 余额不足!"'\E[0m')
		else
			gas_balance=$(echo '\E[1;32m'${balance}'\E[0m'"PHA")
		fi

		clear
		printf "
------------------------------ Script version ${script_version} ----------------------------
	service name		service status		local node block height
--------------------------------------------------------------------------
	khala-node		${node_status}			${khala_node_block} / ${khala_head_block}
	kusama-node		${node_status}			${kusama_node_block} / ${kusama_head_block}
	phala-pruntime		${pruntime_status}
	phala-pherry		${pherry_status}			khala ${blocknum} / kusama ${headernum}
--------------------------------------------------------------------------
	Status check						result
--------------------------------------------------------------------------
	khala chain synchronization status		${sync_status[0]}, difference is ${diff[0]}
	kusama chain synchronization status		${sync_status[1]}, difference is ${diff[1]}
	pherry synchronizes khala chain status		${sync_status[2]}, difference is ${diff[2]}
	pherry syncs kusama chain status  		${sync_status[3]}, difference is ${diff[3]}
--------------------------------------------------------------------------
	account information		content
--------------------------------------------------------------------------
	node name           		${node_name}
	cores     			${cores}
	GAS account address      	${gas_address}
	GAS account balance      	${gas_balance}
	stake pool account address	${pool_address}
	miner/worker public key 	${publickey}
	miner registration status	${registerStatus}
	miner score			${score}
--------------------------------------------------------------------------
"

		echo "Please wait for the miner registration status to change to "registered" before proceeding on-chain operations"
		echo "If the chain synchronization is completed, but the pherry height is empty, please enter the group and ask"

		for i in `seq 60 -1 0`; do
			echo -ne "----------------------  Remaining ${i}s refresh   --------------------------\r"
			sleep 1
		done
		printf "\n Refreshing..."
	done
}
