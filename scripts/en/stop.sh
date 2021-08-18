#!/bin/bash

help_stop()
{
cat << EOF
Usage:
	node					stop phala-node container 
	pruntime					stop phala-pruntime container
	pherry					stop phala-pherry container
	bench					stop phala-bench container
EOF
exit 0
}

stop()
{
	case $1 in
		"")
			for container_name in phala-node phala-pruntime phala-pherry phala-pruntime-bench khala-node
			do
				if [ ! -z $(docker container ls -q -f "name=$container_name") ]; then docker container rm --force $container_name; fi
			done
			;;
		node)
			if [ ! -z $(docker container ls -q -f "name=phala-node") ]; then
				docker container rm --force phala-node
			else
				log_info "----------phala-node already stop----------"
			fi
			;;
		pruntime)
			if [ ! -z $(docker container ls -q -f "name=phala-pruntime") ]; then
				docker container rm --force phala-pruntime
			else
				log_info "----------phala-pruntime already stop----------"
			fi
			;;
		pherry)
			if [ ! -z $(docker container ls -q -f "name=phala-pherry") ]; then
				docker container rm --force phala-pherry
			else
				log_info "----------phala-pherry already stop----------"
			fi
			;;
		bench)
			if [ ! -z $(docker container ls -q -f "name=phala-pruntime-bench") ]; then
				docker container rm --force phala-pruntime-bench
			else
				log_info "----------phala-pruntime-bench already stop----------"
			fi
			;;
		*)
			help_stop
			break
	esac
}
