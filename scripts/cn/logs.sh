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
			log_err "----------参数错误----------"
			exit 1
	esac
}