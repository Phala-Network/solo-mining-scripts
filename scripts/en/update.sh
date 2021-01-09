#!/bin/bash

clean()
{
    log_info "----------Clean phala node images----------"
    log_info "Kill phala-node phala-pruntime phala-phost"
    docker kill phalaphost
    docker kill phalapruntime
    docker kill phalanode
    docker image prune -a

    log_info "----------Clean data----------"
    rm -r $HOME/phalanodedata
    rm -r $HOME/phalapruntimedata

    local res=0
    log_info "----------Pull docker images----------"
    docker pull phalanetwork/phala-poc3-node
    res=$(($?|$res))
    docker pull phalanetwork/phala-poc3-pruntime
    res=$(($?|$res))
    docker pull phalanetwork/phala-poc3-phost
    res=$(($?|$res))

    if [ $res -ne 0 ]; then
        log_err "----------docker pull failed----------"
    fi

    log_success "----------Clean success----------"
}

update_noclean()
{
    log_info "----------Update phala node----------"
    log_info "Kill phala-node phala-pruntime phala-phost"
    docker kill phalaphost
    docker kill phalapruntime
    docker kill phalanode
    docker image prune -a

    local res=0
    docker pull phalanetwork/phala-poc3-node
    res=$(($?|$res))
    docker pull phalanetwork/phala-poc3-pruntime
    res=$(($?|$res))
    docker pull phalanetwork/phala-poc3-phost
    res=$(($?|$res))

    if [ $res -ne 0 ]; then
        log_err "----------docker pull failed----------"
    fi

    log_success "----------Update success----------"
}

update()
{
	case "$1" in
		clean)
			clean
			;;
        "")
            update_noclean
            ;;
        *)
            log_err "----------Parameter error----------"
	esac
}
