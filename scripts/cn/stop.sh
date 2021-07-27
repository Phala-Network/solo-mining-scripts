#!/bin/bash

stop()
{
	cd $installdir
	docker-compose stop
	if [ $? -ne 0 ]; then
		log_err "----------phala组件停止失败----------"
		exit 1
	fi
}
