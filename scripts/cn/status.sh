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
		local balance=$(node $installdir/console.js --substrate-ws-endpoint "wss://khala.api.onfinality.io/public-ws" chain free-balance $gas_address 2>&1)
		balance=$(echo $balance | awk -F " " '{print $NF}')
		balance=$(echo "$balance / 1000000000000"|bc)
		local khala_head_block=$(node $installdir/console.js --substrate-ws-endpoint "wss://khala.api.onfinality.io/public-ws" chain sync-state 2>/dev/null)
		khala_head_block=$(echo $khala_head_block | awk -F "," '{print $5}' | sed 's/ currentBlock: //g')
		local khala_node_block=$(curl -sH "Content-Type: application/json" -d '{"id":1, "jsonrpc":"2.0", "method": "system_syncState", "params":[]}' http://node.phala.asia:9933 | jq '.result.currentBlock')
		local kusama_head_block=$(node $installdir/console.js --substrate-ws-endpoint "wss://pub.elara.patract.io/kusama" chain sync-state | awk -F " " '/currentBlock/ {print $NF}' | sed 's/,//g')
		local kusama_node_block=$(curl -sH "Content-Type: application/json" -d '{"id":1, "jsonrpc":"2.0", "method": "system_syncState", "params":[]}' http://node.phala.asia:9934 | jq '.result.currentBlock')
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

		SYNCED="同步完成"
		SYNCING="同步中, 请等待"

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
			registerStatus="已注册"
		else
			registerStatus="未注册"
		fi

		if [ $(echo "$balance < 2"|bc) -eq 1 ]; then
			gas_balance=$(echo '\E[1;33m'${balance}'\E[0m'"PHA"'\E[41;33m'" 余额不足!"'\E[0m')
		else
			gas_balance=$(echo '\E[1;32m'${balance}'\E[0m'"PHA")
		fi

		clear
		printf "
---------------------------   60s刷新   ----------------------------------
--------------------------------------------------------------------------
	服务名称		服务状态		本地节点区块高度
--------------------------------------------------------------------------
	khala-node		${node_status}			${khala_node_block} / ${khala_head_block}
	kusama-node		${node_status}			${kusama_node_block} / ${kusama_head_block}
	phala-pruntime		${pruntime_status}
	phala-pherry		${pherry_status}			khala ${blocknum} / kusama ${headernum}
--------------------------------------------------------------------------
	状态检查		结果
--------------------------------------------------------------------------
	khala链同步状态		${sync_status[0]}, 差值为 ${diff[0]}
	kusama链同步状态	${sync_status[1]}, 差值为 ${diff[1]}
	pherry同步khala链状态	${sync_status[2]}, 差值为 ${diff[2]}
	pherry同步kusama链状态  ${sync_status[3]}, 差值为 ${diff[3]}
--------------------------------------------------------------------------
	账户信息		内容
--------------------------------------------------------------------------
	节点名称           	${node_name}
	计算机使用核心     	${cores}
	GAS费账户地址      	${gas_address}
	GAS费账户余额      	${gas_balance}
	抵押池账户地址      	${pool_address}
	矿工公钥		${publickey}
	矿工注册状态		${registerStatus}
	矿工评分		${score}
--------------------------------------------------------------------------
"

		echo "------------- 请等待矿工注册状态变为「已注册」再进行链上操作 -------------"
		echo "----------- 如果矿工公钥为空，请等待 khala 与 kusama 节点同步 ------------"

		for i in `seq 60 -1 1`; do
			echo -ne "--------------------------  剩余 ${i}s刷新   ------------------------------\r"
			sleep 1
		done
		printf "\n 刷新中..."
	done
}
