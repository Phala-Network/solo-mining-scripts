#!/bin/bash

status()
{
	trap "clear;exit" 2
	while true; do
		local node_status="stop"
		local pruntime_status="stop"
		local pherry_status="stop"
		local node_name="yfj-test"
		local cores=6
		local mnemonic=sjdflks sjdflk jslkdfjdlkj ldsjflk jsdlkjf lksdj lkfjdlk
		local gas_address=skldfjlkskdjflksjflkjsdlkfjlksdjflskdjfsla;fjdal;sl
		local pool_address=0xskjdflksjfiosjgosiopwqprlwj;lkj
		local balance=1
		local node_block=7823784783
		local publickey=0xskjdflksjfiosjgosiopwqprlwjsdfsd;lfk;sdkf;lsd

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
	Worker-publish-key	${publickey}
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
	Worker-publish-key	${publickey}
--------------------------------------------------------------------------
"
		fi
		sleep 60
	done
}
