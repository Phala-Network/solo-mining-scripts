#!/bin/bash

function logs()
{
	case $1 in
		"")
			cd $installdir
			docker-compose logs -f
			;;
		node)
			if [ ! -z $(docker container ls -q -f "name=phala-node") ]; then
				docker logs -f phala-node
			else
				log_info "----------phala-node容器已经停止----------"
			fi
			;;
		pruntime)
			if [ ! -z $(docker container ls -q -f "name=phala-pruntime") ]; then
				docker logs -f phala-pruntime
			else
				log_info "----------phala-pruntime容器已经停止----------"
			fi
			;; 
		pherry)
			if [ ! -z $(docker container ls -q -f "name=phala-pherry") ]; then
				docker logs -f phala-pherry
			else
				log_info "----------phala-pherry容器已经停止----------"
			fi
			;;
		bench)
			if [ ! -z $(docker container ls -q -f "name=phala-pruntime-bench") ]; then
				docker logs -f phala-pruntime-bench
			else
				log_info "----------phala-pruntime-bench容器已经停止----------"
			fi
			;;
		*)
			phala_help
			break
	esac
}