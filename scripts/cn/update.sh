#!/bin/bash

update_script()
{
	log_info "----------更新 phala 脚本----------"

	mkdir -p /tmp/phala
	wget https://github.com/Phala-Network/solo-mining-scripts/archive/main.zip -O /tmp/phala/main.zip
	unzip /tmp/phala/main.zip -d /tmp/phala
	rm -rf /opt/phala/scripts
	cp -r /tmp/phala/solo-mining-scripts-main/scripts/cn /opt/phala/scripts
	mv /opt/phala/scripts/phala.sh /usr/bin/phala
	chmod +x /usr/bin/phala
	chmod +x /opt/phala/scripts/*

	log_success "----------更新完成----------"
	rm -rf /tmp/phala
}

update_clean()
{
	log_info "----------删除 Docker 镜像----------"
	log_info "关闭 phala-node phala-pruntime phala-phost"
	docker kill phala-phost
	docker kill phala-pruntime
	docker kill phala-node
	docker image prune -a

	log_info "----------删除节点数据----------"
	rm -r $HOME/phala-node-data
	rm -r $HOME/phala-pruntime-data

	local res=0
	log_info "----------更新 Docker 镜像----------"
	docker pull swr.cn-east-3.myhuaweicloud.com/phala/phala-poc3-node
	res=$(($?|$res))
	docker pull swr.cn-east-3.myhuaweicloud.com/phala/phala-poc3-pruntime
	res=$(($?|$res))
	docker pull swr.cn-east-3.myhuaweicloud.com/phala/phala-poc3-phost
	res=$(($?|$res))

	if [ $res -ne 0 ]; then
		log_err "----------docker 镜像下载失败----------"
	fi

	log_success "----------成功删数据更新----------"
}

update_noclean()
{
	log_info "----------更新挖矿套件镜像----------"
	log_info "关闭 phala-node phala-pruntime phala-phost"
	docker kill phala-phost
	docker kill phala-pruntime
	docker kill phala-node
	docker image prune -a

	local res=0
	docker pull swr.cn-east-3.myhuaweicloud.com/phala/phala-poc3-node
	res=$(($?|$res))
	docker pull swr.cn-east-3.myhuaweicloud.com/phala/phala-poc3-pruntime
	res=$(($?|$res))
	docker pull swr.cn-east-3.myhuaweicloud.com/phala/phala-poc3-phost
	res=$(($?|$res))

	if [ $res -ne 0 ]; then
		log_err "----------docker下载失败----------"
	fi

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
