#!/bin/bash

stop()
{
	cd $installdir
	docker-compose stop
	if [ $? -ne 0 ]; then
		log_err "----------Stop failed----------"
		exit 1
	fi
}
