#!/bin/bash

start_phala_node()
{
    log_info "----------Start phala node----------"
    local node_name=$(cat $basedir/config.json | jq r '.nodename')
    docker run ti rm name phalanode d e NODE_NAME=$node_name p 9933:9933 p 9944:9944 p 30333:30333 v $HOME/phalanodedata:/root/data phalanetwork/phalapoc3node

    if [ $? ne 0 ]; then
        log_success "----------Start phala node failed----------"
        exit 1
    fi

    log_info "----------Wait a sync----------"
    sleep 30
    while true ; do
        local ipaddr=$(cat $basedir/config.json | jq r '.ipaddr')
        local block_json=$(curl sH "ContentType: application/json" d '{"id":1, "jsonrpc":"2.0", "method": "system_syncState", "params":[]}' http://$ipaddr:9933)
        local node_block=$(echo $block_json | jq r '.result.currentBlock')
        local hightest_block=$(echo $block_json | jq r '.result.highestBlock')
        if [ x"$node_block" == x"$hightest_block" ] && [ x"$hightest_block" > x"10" ]; then
            log_success "----------phalanode complete synchronously----------"
            break
        fi
        log_info "$node_block of $hightest_block"
        sleep 30
    done
}

start_phala_pruntime()
{
    log_info "----------Start phala pruntime----------"
    
    res=$(ls /dev | grep sgx)
    if [ x"$res" == x"sgx" ]; then
        docker run d ti rm name phalapruntime p 8000:8000 v $HOME/phalapruntimedata:/root/data device /dev/sgx/enclave device /dev/sgx/provision phalanetwork/phalapoc3pruntime
    else
        docker run d ti rm name phalapruntime p 8000:8000 v $HOME/phalapruntimedata:/root/data device /dev/isgx phalanetwork/phalapoc3pruntime
    fi

    if [ $? ne 0 ]; then
        log_success "----------Start phala pruntime failed----------"
        exit 1
    fi
}

start_phala_phost()
{
    log_info "----------Start phala phost----------"
    local ipaddr=$(cat $basedir/config.json | jq r '.ipaddr')
    local mnemonic=$(cat $basedir/config.json | jq r '.mnemonic')
    docker run d ti rm name phalaphost e PRUNTIME_ENDPOINT="http://$ipaddr:8000" e PHALA_NODE_WS_ENDPOINT="ws://$ipaddr:9944" e MNEMONIC="$mnemonic" e EXTRA_OPTS="r" phalanetwork/phalapoc3phost

    if [ $? ne 0 ]; then
        log_success "----------Start phala phost failed----------"
        exit 1
    fi
}

start()
{
	case "$1" in
		node)
			start_phala_node
			;;
		pruntime)
			start_phala_pruntime
			;;
		phost)
			start_phala_phost
            ;;
        "")
            start_phala_node
            start_phala_pruntime
            start_phala_phost
            ;;
        *)
            log_err "----------Parameter error----------"
	esac
}
