#!/bin/bash

logs()
{
    case "$1" in
		node)
			docker logs phala-node
			;;
		pruntime)
			docker logs phala-pruntime
			;;
		phost)
			docker logs phala-phost
            ;;
        *)
            log_err "----------Parameter error----------"
			exit 1
	esac
}