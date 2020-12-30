#!/bin/bash

status()
{
	local ipaddr=$(jq -r '.ipaddr' $basedir/config.json)
    local node_status="stop"
	local node_block=$(curl -sH "Content-Type: application/json" -d '{"id":1, "jsonrpc":"2.0", "method": "system_syncState", "params":[]}' http://$ipaddr:9933 | jq '.result.currentBlock')
    local pruntime_status="stop"
    local phost_status="stop"

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

    check_docker_status phala-phost
    local res=$?
	if [ $res -eq 0 ]; then
		phost_status="running"
	elif [ $res -eq 2 ]; then
		phost_status="exited"
	fi

    cat << EOF
-----------------------------------------------------------------------
    Service   服务               Status	状态         CurrentBlock 本地节点区块高度
-----------------------------------------------------------------------
    phala-node                  ${node_status}		${node_block}
    phala-pruntime              ${pruntime_status}
    phala-phost                 ${phost_status}
------------------------------------------------------------------------
EOF
}
