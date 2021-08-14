#!/bin/bash

uninstall()
{
	cd $installdir
	docker-compose stop
	for container_name in phala-node phala-pruntime phala-pherry khala-node phala-pruntime-bench
	do
		if [ ! -z $(docker ps -qf "name=$container_name") ]; then
			docker container rm --force $container_name
			case $container_name in
				phala-node)
					docker image rm $(awk -F "=" 'NR==1 {print $2}' $installdir/.env)
					rm -rf $(awk -F '[=:]' 'NR==4 {print $2}' $installdir/.env)
					;;
				phala-pruntime)
					docker image rm $(awk -F "=" 'NR==2 {print $2}' $installdir/.env)
					rm -rf $(awk -F '[=:]' 'NR==5 {print $2}' $installdir/.env)
					;;
				phala-pherry)
					docker image rm $(awk -F "=" 'NR==3 {print $2}' $installdir/.env)
					;;
				khala-node)
					docker image rm phalanetwork/khala-node
					;;
				phala-pruntime-bench)
					docker image rm swr.cn-east-3.myhuaweicloud.com/phala/phala-dev-pruntime-bench
					;;
				*)
					break
			esac
		fi
	done
	remove_dirver
	rm -rf $installdir
	rm /usr/bin/phala

	log_success "---------------删除 phala 挖矿套件成功---------------"
}
