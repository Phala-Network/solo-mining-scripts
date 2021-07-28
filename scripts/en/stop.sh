#!/bin/bash

stop()
{
	cd $installdir
	docker-compose stop
	docker-compose rm phala-node phala-pruntime phala-pherry
	if [ $? -ne 0 ]; then
		log_err "----------Stop failed----------"
		exit 1
	fi
}
