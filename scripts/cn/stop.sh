#!/bin/bash

help_stop()
{
cat << EOF
Usage:
	node					停止phala-node容器
	pruntime				停止phala-pruntime容器
	pherry					停止phala-pherry容器
	bench					停止phala-pruntime-bench容器
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
				log_info "----------phala-node容器已经停止----------"
			fi
			;;
		pruntime)
			if [ ! -z $(docker container ls -q -f "name=phala-pruntime") ]; then
				docker container rm --force phala-pruntime
			else
				log_info "----------phala-pruntime容器已经停止----------"
			fi
			;; 
		pherry)
			if [ ! -z $(docker container ls -q -f "name=phala-pherry") ]; then
				docker container rm --force phala-pherry
			else
				log_info "----------phala-pherry容器已经停止----------"
			fi
			;;
		bench)
			if [ ! -z $(docker container ls -q -f "name=phala-pruntime-bench") ]; then
				docker container rm --force phala-pruntime-bench
			else
				log_info "----------phala-pruntime-bench容器已经停止----------"
			fi
			;;
		*)
			help_stop
			break
	esac
}
