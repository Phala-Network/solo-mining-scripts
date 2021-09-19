#!/bin/bash

function check_version()
{
	if ! type wget unzip > /dev/null; then apt-get install -y wget unzip;fi
	wget https://github.com/Phala-Network/solo-mining-scripts/archive/para.zip -O /tmp/para.zip &> /dev/null
	unzip -o /tmp/para.zip -d /tmp/phala &> /dev/null
	if [ "$(cat $installdir/.env | awk -F "=" 'NR==15 {print $NF}')" != "$(cat /tmp/phala/solo-mining-scripts-para/.env | awk -F "=" 'NR==15 {print $NF}')" ]; then
		rm -rf /opt/phala/scripts /usr/bin/phala
		cp -r /tmp/phala/solo-mining-scripts-para/scripts/en /opt/phala/scripts
		cp -r /tmp/phala/solo-mining-scripts-para/docker-compose.yml /opt/phala
		chmod +x /opt/phala/scripts/phala.sh
		ln -s /opt/phala/scripts/phala.sh /usr/bin/phala
		log_info "----------The local script version is too low and has been automatically upgraded. Please execute the command again!----------"
		exit 1
	fi
	rm -rf /tmp/phala /tmp/para.zip
}

function update_script()
{
	log_info "----------Update phala script----------"
	wget https://github.com/Phala-Network/solo-mining-scripts/archive/para.zip -O /tmp/para.zip &> /dev/null
	unzip -o /tmp/para.zip -d /tmp/phala &> /dev/null
	rm -rf /opt/phala/scripts /usr/bin/phala
	cp -r /tmp/phala/solo-mining-scripts-para/scripts/en /opt/phala/scripts
	cp -r /tmp/phala/solo-mining-scripts-para/scripts/en /opt/phala/scripts
	cp -r /tmp/phala/solo-mining-scripts-para/docker-compose.yml /opt/phala
	chmod +x /opt/phala/scripts/phala.sh
	ln -s /opt/phala/scripts/phala.sh /usr/bin/phala
	log_success "----------Update success----------"
	rm -rf /tmp/phala /tmp/para.zip
}

function update_clean()
{
	log_info "----------Clean phala node images----------"
	log_info "Kill phala-node phala-pruntime phala-pherry phala-pruntime-bench khala-node"
	log_info "----------Clean data----------"
	for container_name in phala-node phala-pruntime phala-pherry phala-pruntime-bench khala-node phala-sgx_detect
	do
		if [ ! -z $(docker container ls -q -f "name=$container_name") ]; then
			docker container stop $container_name
			docker container rm --force $container_name
			case $container_name in
				phala-node)
					docker image rm $(awk -F "=" 'NR==1 {print $2}' $installdir/.env)
					local node_dir=$(awk -F '[=:]' 'NR==4 {print $2}' $installdir/.env)
					if [ -d $node_dir ]; then rm -rf $node_dir;fi
					;;
				phala-pruntime) 
					docker image rm $(awk -F "=" 'NR==2 {print $2}' $installdir/.env)
					local pruntime_dir=$(awk -F '[=:]' 'NR==5 {print $2}' $installdir/.env)
					if [ -d $pruntime_dir ]; then rm -rf $pruntime_dir;fi
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
	log_success "----------Clean success----------"

	start
}

function update_noclean()
{
	log_info "----------Update phala node----------"
	log_info "Kill phala-node phala-pruntime phala-pherry phala-pruntime-bench khala-node"
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
	log_success "----------Update success----------"
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
