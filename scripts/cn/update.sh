#!/bin/bash

update_script()
{
	log_info "----------更新 phala 脚本----------"

	mkdir -p /tmp/phala
	wget https://github.com/Phala-Network/solo-mining-scripts/archive/main.zip -O /tmp/phala/main.zip
	unzip /tmp/phala/main.zip -d /tmp/phala
	rm -rf /opt/phala/scripts
	cp -r /tmp/phala/solo-mining-scripts-main/scripts/cn /opt/phala/scripts
	chmod +x /opt/phala/scripts/*
	ln -s /opt/phala/scripts/phala.sh /usr/bin/phala

	log_success "----------更新完成----------"
	rm -rf /tmp/phala
}

update_clean()
{
	log_info "----------删除 Docker 镜像----------"
	log_info "关闭 phala-node phala-pruntime phala-pherry"
	cd $installdir
	docker-compose stop
	docker-compose rm phala-node phala-pruntime phala-pherry
	docker image rm phala-node phala-pruntime phala-pherry

	log_info "----------删除节点数据----------"
	local node_data=$(awk -F '[=:]' 'NR==4 {print $2}' $installdir/.env)
	local pruntime_data=$(awk -F '[=:]' 'NR==5 {print $2}' $installdir/.env)
	if [ -f $node_data ]; then
		rm -rf $node_data
	elif [ -f $pruntime_data ]; then
		rm -rf $pruntime_data
	fi
	log_success "----------成功删数据----------"

	phala start
}

update_noclean()
{
	log_info "----------更新挖矿套件镜像----------"
	log_info "关闭 phala-node phala-pruntime phala-pherry"
	cd $installdir
	docker-compose stop
	docker-compose rm phala-node phala-pruntime phala-pherry
	docker image rm phala-node phala-pruntime phala-pherry

	phala start
	log_success "----------更新成功----------"
}

update()
{
	case "$1" in
		clean)
			update_clean
			;;
		script)
			update_script
			;;
		"")
			update_noclean
			;;
		*)
			log_err "----------参数错误----------"
	esac
}
