#!/bin/bash

help_stop()
{
cat << EOF
Usage:
	phala-node					stop phala-node container 
	phala-pruntime					stop phala-pruntime container
	phala-pherry					stop phala-pherry container
	phala-bench					stop phala-bench container
EOF
exit 0
}

stop()
{
	case $1 in
		phala-node)
			if [ ! -z $(docker ps -qf "name=phala-node") ]; then
				docker container stop phala-node
			else
				log_info "----------phala-node already stop----------"
			fi
			;;
		phala-pruntime)
			if [ ! -z $(docker ps -qf "name=phala-pruntime") ]; then
				docker container stop phala-pruntime
			else
				log_info "----------phala-pruntime already stop----------"
			fi
			;;
		phala-pherry)
			if [ ! -z $(docker ps -qf "name=phala-pherry") ]; then
				docker container stop phala-pruntime
			else
				log_info "----------phala-pherry already stop----------"
			fi
			;;
		phala-bench)
			if [ ! -z $(docker ps -qf "name=phala-bench") ]; then
				docker container stop phala-bench
			else
				log_info "----------phala-bench already stop----------"
			fi
			;;
		*)
			help_stop
			break
	esac
}
