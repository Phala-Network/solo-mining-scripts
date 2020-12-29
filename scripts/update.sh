#!/bin/bash

clean()
{
    log_info "--------------Clean phala node-------------"
    log_info "Kill phala-phost phala-pruntime phala-node"
    docker kill phala-phost
    docker kill phala-pruntime
    docker kill phala-node

    log_info "Clean data"
    rm -r $HOME/phala-node-data
    rm -r $HOME/phala-pruntime-data
    docker image prune -a

    download_docker_images

    if [ $? -ne 0 ]; then
        log_success "------------Clean success-------------"
    fi
}

update_noclean()
{
    log_info "--------------Update phala node-------------"
    log_info "Kill phala-phost phala-pruntime phala-node"
    docker kill phala-phost
    docker kill phala-pruntime
    docker kill phala-node

    docker image prune -a
    download_docker_images

    if [ $? -ne 0 ]; then
        log_success "------------Clea success-------------"
    fi
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
            log_err "Parameter error"
	esac
}
