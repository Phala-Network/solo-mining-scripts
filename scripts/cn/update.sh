#!/bin/bash

clean()
{
    log_info "----------删除 Docker 镜像----------"
    log_info "关闭 phala-node phala-pruntime phala-phost"
    docker kill phalaphost
    docker kill phalapruntime
    docker kill phalanode
    docker image prune -a

    log_info "----------删除节点数据----------"
    rm -r $HOME/phalanodedata
    rm -r $HOME/phalapruntimedata

    local res=0
    log_info "----------更新 Docker 镜像----------"
    docker pull phalanetwork/phala-poc3-node
    res=$(($?|$res))
    docker pull phalanetwork/phala-poc3-pruntime
    res=$(($?|$res))
    docker pull phalanetwork/phala-poc3-phost
    res=$(($?|$res))

    if [ $res -ne 0 ]; then
        log_err "----------docker 镜像下载失败----------"
    fi

    log_success "----------成功删数据更新----------"
}

update_noclean()
{
    log_info "----------更新挖矿套件镜像----------"
    log_info "关闭 phala-node phala-pruntime phala-phost"
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
        log_err "----------docker下载失败----------"
    fi

    log_success "----------更新成功----------"
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
            log_err "----------参数错误----------"
	esac
}
