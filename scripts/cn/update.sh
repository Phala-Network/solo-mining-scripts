#!/bin/bash

function check_version()
{
	if ! type wget unzip; then apt-get install -y wget unzip;fi
	wget https://github.com/Phala-Network/solo-mining-scripts/archive/para.zip -O /tmp/main.zip
	unzip -o /tmp/main.zip -d /tmp/phala
	if [ "$(cat $installdir/.env | awk -F "=" 'NR==15 {print $NF}')" != "$(cat /tmp/phala/solo-mining-scripts-para/.env | awk -F "=" 'NR==15 {print $NF}')" ]; then
		cp $installdir/.env /tmp/phala/solo-mining-scripts-para
		rm -rf /opt/phala /usr/bin/phala
 		mkdir /opt/phala
		cp /tmp/phala/solo-mining-scripts-para/{.env,console.js,docker-compose.yml} /opt/phala
		cp -r /tmp/phala/solo-mining-scripts-para/scripts/cn /opt/phala/scripts
		chmod +x /opt/phala/scripts/phala.sh
		ln -s /opt/phala/scripts/phala.sh /usr/bin/phala
		log_info "----------本地脚本版本过低，已自动升级。请重新执行命令！----------"
		exit 1
	fi
	rm -rf /tmp/phala /tmp/main.zip
}

function update_script()
{
	log_info "----------更新 phala 脚本----------"

	wget https://github.com/Phala-Network/solo-mining-scripts/archive/para.zip -O /tmp/main.zip
	unzip -o /tmp/main.zip -d /tmp/phala
	cp $installdir/.env /tmp/phala/solo-mining-scripts-para
	rm -rf /opt/phala /usr/bin/phala
	mkdir /opt/phala
	cp /tmp/phala/solo-mining-scripts-para/{.env,console.js,docker-compose.yml} /opt/phala
	cp -r /tmp/phala/solo-mining-scripts-para/scripts/cn /opt/phala/scripts
	chmod +x /opt/phala/scripts/phala.sh
	ln -s /opt/phala/scripts/phala.sh /usr/bin/phala

	log_success "----------更新完成----------"
	rm -rf /tmp/phala /tmp/main.zip
}

function update_clean()
{
	log_info "----------删除 Docker 镜像----------"
	log_info "关闭 phala-node phala-pruntime phala-pherry phala-pruntime-bench khala-node"
	log_info "----------删除节点数据----------"
	for container_name in phala-node phala-pruntime phala-pherry phala-pruntime-bench khala-node phala-sgx_detect
	do
		if [ ! -z $(docker container ls -q -f "name=$container_name") ]; then
			docker container stop $container_name
			docker container rm --force $container_name
			case $container_name in
				phala-node)
					docker image rm $(awk -F "=" 'NR==1 {print $2}' $installdir/.env)
					if [ -d $(awk -F '[=:]' 'NR==4 {print $2}' $installdir/.env) ]; then rm -rf $(awk -F '[=:]' 'NR==4 {print $2}' $installdir/.env);fi
					;;
				phala-pruntime) 
					docker image rm $(awk -F "=" 'NR==2 {print $2}' $installdir/.env)
					if [ -d $(awk -F '[=:]' 'NR==5 {print $2}' $installdir/.env) ]; then rm -rf $(awk -F '[=:]' 'NR==5 {print $2}' $installdir/.env);fi
					;;
				phala-pherry)
					docker image rm $(awk -F "=" 'NR==3 {print $2}' $installdir/.env) 
					;;
				khala-node)
					docker image rm phalanetwork/khala-node
					if [ -d /var/khala-dev-node ]; then rm -rf /var/khala-dev-node;fi
					;;
				*)
					break
			esac
		fi
	done
	log_success "----------成功删数据----------"

	start
}

function update_noclean()
{
	log_info "----------更新挖矿套件镜像----------"
	log_info "关闭 phala-node phala-pruntime phala-pherry phala-pruntime-bench khala-node"
	for container_name in phala-node phala-pruntime phala-pherry phala-pruntime-bench khala-node phala-sgx_detect
	do
		if [ ! -z $(docker container ls -q -f "name=$container_name") ]; then
			docker container stop $container_name
			docker container rm --force $container_name
			case $container_name in
				phala-node)
					docker image rm $(awk -F "=" 'NR==1 {print $2}' $installdir/.env)
					;;
				phala-pruntime)
					docker image rm $(awk -F "=" 'NR==2 {print $2}' $installdir/.env)
					;;
				phala-pherry)
					docker image rm $(awk -F "=" 'NR==3 {print $2}' $installdir/.env) 
					;;
				khala-node)
					docker image rm phalanetwork/khala-node
					if [ -d /var/khala-dev-node ]; then rm -rf /var/khala-dev-node;fi
					;;
				*)
					break
			esac
		fi
	done

	start
	log_success "----------更新成功----------"
}

function update()
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
			phala_help
			break
	esac
}
