#!/bin/bash

uninstall()
{
	cd $installdir
	docker-compose stop
	docker container rm phala-node phala-pruntime phala-pherry
	docker image rm $(awk -F '[=]' 'NR==1,NR==3 {print $2}' $installdir/.env)
	remove_dirver
	rm -rf $installdir $(awk -F '[=:]' 'NR==4,NR==5 {print $2}' $installdir/.env)
	rm /usr/bin/phala

	log_success "---------------Uninstall phala node sucess---------------"
}
