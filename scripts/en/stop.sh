#!/bin/bash

stop_phala_node()
{
	log_info "----------Stop phala node----------"
	docker kill phala-node

	if [ $? -ne 0 ]; then
		log_err "----------Stop failed----------"
		exit 1
	fi
}

stop_phala_pruntime()
{
	log_info "----------Stop phala pruntime----------"
	docker kill phala-pruntime

	if [ $? -ne 0 ]; then
		log_err "----------Stop failed----------"
		exit 1
	fi
}

stop_phala_phost()
{
	log_info "----------Stop phala phost----------"
	docker kill phala-phost

	if [ $? -ne 0 ]; then
		log_err "----------Stop failed----------"
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
			log_err "----------Parameter error----------"
	esac
}
