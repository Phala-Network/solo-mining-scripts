#!/bin/bash

uninstall()
{
	cd $installdir
	docker-compose stop
	docker-compose rm phala-node phala-pruntime phala-pherry
	docker image rm phala-dev-node phala-dev-pruntime phala-dev-pherry # 合并到main时，更新image名字
	remove_dirver
	rm -rf $installdir
	rm /usr/bin/phala

	log_success "---------------Uninstall phala node sucess---------------"
}
