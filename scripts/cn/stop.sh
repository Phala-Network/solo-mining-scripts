#!/bin/bash

stop_phala_node()
{
	log_info "----------停止 phala-node 组件----------"
	docker kill phala-node

	if [ $? ne 0 ]; then
		log_err "----------停止 phala-node 组件失败----------"
		exit 1
	fi
}

stop_phala_pruntime()
{
	log_info "----------停止 phala-pruntime 组件----------"
	docker kill phala-pruntime

	if [ $? ne 0 ]; then
		log_err "----------停止 phala-pruntime 组件失败----------"
		exit 1
	fi
}

stop_phala_phost()
{
	log_info "----------停止 phala-phost 组件----------"
	docker kill phala-phost

	if [ $? ne 0 ]; then
		log_err "----------停止 phala-phost 组件失败----------"
		exit 1
	fi
}

stop()
{
	case "$1" in
		node)
			stop_phala_node
			;;
		pruntime)
			stop_phala_pruntime
			;;
		phost)
			stop_phala_phost
			;;
		"")
			stop_phala_node
			stop_phala_pruntime
			stop_phala_phost
			break
			;;
		*)
			log_err "----------参数错误----------"
	esac
	exit 0
}
