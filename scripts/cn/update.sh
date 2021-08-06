#!/bin/bash

check_version()
{
	wget https://github.com/Phala-Network/solo-mining-scripts/archive/poc5.zip -O /tmp/main.zip
	unzip -o /tmp/main.zip -d /tmp/phala
	if [ $(cat $installdir/.env | awk -F "=" '{print $NF}') != $(cat /tmp/phala/solo-mining-scripts-poc5/.env | awk -F "=" '{print $NF}') ]; then
		rm -rf /opt/phala/scripts
		rm /usr/bin/phala
		cp -r /tmp/phala/solo-mining-scripts-poc5/scripts/cn /opt/phala/scripts
		cp -r /tmp/phala/solo-mining-scripts-poc5/.env /opt/phala/
		cp -r /tmp/phala/solo-mining-scripts-poc5/console.js /opt/phala/
		cp -r /tmp/phala/solo-mining-scripts-poc5/docker-compose.yml /opt/phala/
		chmod +x /opt/phala/scripts/*
		ln -s /opt/phala/scripts/phala.sh /usr/bin/phala
		exit 1
	fi
	rm -rf /tmp/phala
	rm /tmp/main.zip
}

update_script()
{
	log_info "----------更新 phala 脚本----------"

	mkdir -p /tmp/phala
	wget https://github.com/Phala-Network/solo-mining-scripts/archive/poc5.zip -O /tmp/main.zip
	unzip -o /tmp/main.zip -d /tmp/phala
	rm -rf /opt/phala
	rm /usr/bin/phala
	mkdir /opt/phala
	cp -r /tmp/phala/solo-mining-scripts-poc5/scripts/cn /opt/phala/scripts
	cp -r /tmp/phala/solo-mining-scripts-poc5/.env /opt/phala/
	cp -r /tmp/phala/solo-mining-scripts-poc5/console.js /opt/phala/
	cp -r /tmp/phala/solo-mining-scripts-poc5/docker-compose.yml /opt/phala/
	chmod +x /opt/phala/scripts/*
	ln -s /opt/phala/scripts/phala.sh /usr/bin/phala

	log_success "----------更新完成----------"
	rm -rf /tmp/phala
	rm /tmp/main.zip
}

update_clean()
{
	log_info "----------删除 Docker 镜像----------"
	log_info "关闭 phala-node phala-pruntime phala-pherry"
	cd $installdir
	docker-compose stop
	docker container rm phala-node phala-pruntime phala-pherry
	docker image rm $(awk -F '[=]' 'NR==1,NR==3 {print $2}' $installdir/.env)

	log_info "----------删除节点数据----------"
	local node_data=$(awk -F '[=:]' 'NR==4 {print $2}' $installdir/.env)
	local pruntime_data=$(awk -F '[=:]' 'NR==5 {print $2}' $installdir/.env)
	if [ -d $node_data ]; then
		rm -rf $node_data
	elif [ -d $pruntime_data ]; then
		rm -rf $pruntime_data
	fi
	log_success "----------成功删数据----------"

	start
}

update_noclean()
{
	log_info "----------更新挖矿套件镜像----------"
	log_info "关闭 phala-node phala-pruntime phala-pherry"
	cd $installdir
	docker-compose stop
	docker container rm phala-node phala-pruntime phala-pherry
	docker image rm $(awk -F '[=]' 'NR==1,NR==3 {print $2}' $installdir/.env)

	start
	log_success "----------更新成功----------"
}

update()
{
	case "$1" in
		clean)
			update_clean
			;;
		scripts)
			update_script
			;;
		"")
			update_noclean
			;;
		*)
			log_err "----------参数错误----------"
	esac
}
