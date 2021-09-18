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
				log_info "----------phala-node already stop----------"
			fi
			;;
		pruntime)
			if [ ! -z $(docker container ls -q -f "name=phala-pruntime") ]; then
				docker logs -f phala-pruntime
			else
				log_info "----------phala-pruntime already stop----------"
			fi
			;; 
		pherry)
			if [ ! -z $(docker container ls -q -f "name=phala-pherry") ]; then
				docker logs -f phala-pherry
			else
				log_info "----------phala-pherry already stop----------"
			fi
			;;
		bench)
			if [ ! -z $(docker container ls -q -f "name=phala-pruntime-bench") ]; then
				docker logs -f phala-pruntime-bench
			else
				log_info "----------phala-pruntime-bench already stop----------"
			fi
			;;
		*)
			phala_help
			break
	esac
}