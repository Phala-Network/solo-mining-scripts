#!/bin/bash

install_depenencies()
{
	log_info "----------更新系统源----------"
	apt-get update
	if [ $? -ne 0 ]; then
		log_err "系统源更新失败"
		exit 1
	fi

	log_info "----------安装依赖----------"
	for package in jq curl wget unzip zip docker docker-compose node yq dkms
	do
		if ! type $package > /dev/null 2>&1; then
			case $package in
				jq|curl|wget|unzip|zip|dkms)
					apt-get install -y $package
					;;
				docker)
					curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
					add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
					apt-get install -y docker-ce docker-ce-cli containerd.io
					;;
				docker-compose)
					curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
					chmod +x /usr/local/bin/docker-compose
					;;
				node)
					curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
					apt-get install -y nodejs
					;;
				yq)
					wget https://github.com/mikefarah/yq/releases/download/v4.11.2/yq_linux_amd64.tar.gz -O /tmp/yq_linux_amd64.tar.gz
					tar -xvf /tmp/yq_linux_amd64.tar.gz -C /tmp
					mv /tmp/yq_linux_amd64 /usr/bin/yq
					rm /tmp/yq_linux_amd64.tar.gz
					;;
				*)
					break
			esac
		fi
	done
	# if ! type jq curl wget unzip zip >/dev/null 2>&1; then
	# 	apt-get install -y jq curl wget unzip zip
	# elif ! type docker >/dev/null 2>&1; then
	# 	curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
	# 	add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
	# 	apt-get install -y docker-ce docker-ce-cli containerd.io dkms
	# elif ! type docker-compose >/dev/null 2>&1; then
	# 	curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
	# 	chmod +x /usr/local/bin/docker-compose
	# elif ! type node >/dev/null 2>&1; then
	# 	curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
	# 	apt-get install -y nodejs
	# elif ! type yq >/dev/null 2>&1; then
	# 	wget https://github.com/mikefarah/yq/releases/download/v4.11.2/yq_linux_amd64.tar.gz -O /tmp/yq_linux_amd64.tar.gz
	# 	tar -xvf /tmp/yq_linux_amd64.tar.gz -C /tmp
	# 	mv /tmp/yq_linux_amd64 /usr/bin/yq
	# 	rm /tmp/yq_linux_amd64.tar.gz
	# fi

	usermod -aG docker $USER
}

remove_dirver()
{
	log_info "----------删除旧版本 dcap/isgx 驱动----------"
	# local contents26=$(awk 'NR==26' $installdir/docker-compose.yml)
	# local contents27=$(awk 'NR==27' $installdir/docker-compose.yml)
	# if [ ! -z $contents26 ]&&[ "$contents26" != '  environment: ' ]; then
	# 	sed -i "26c \ " $installdir/docker-compose.yml
	# fi
	
	# if [ ! -z "$contents27" ]&&[ "$contents27" != '  environment: ' ]&&[ "$contents27" != '   - EXTRA_OPTS=--cores=${CORES}' ]; then
	# 	sed -i "27c \ " $installdir/docker-compose.yml
	# fi

	if [ -f /opt/intel/sgxdriver/uninstall.sh ]; then
		/opt/intel/sgxdriver/uninstall.sh
	fi
}

install_driver()
{
	remove_dirver
	log_info "----------下载 DCAP 驱动----------"
	wget $dcap_driverurl -O /tmp/$dcap_driverbin

	if [ $? -ne 0 ]; then
		log_err "----------下载 DCAP 驱动失败----------"
		exit 1
	fi

	log_info "----------为DCAP驱动添加运行权限----------"
	chmod +x /tmp/$dcap_driverbin

	log_info "----------尝试安装DCAP驱动----------"
	/tmp/$dcap_driverbin

	if [ ! -c /dev/sgx_enclave -a ! -c /dev/sgx_provision ]; then
		log_err "----------安装DCAP驱动失败，尝试安装isgx驱动----------"
		remove_dirver
		log_info "----------下载 ISGX 驱动----------"
		wget $isgx_driverurl -O /tmp/$isgx_driverbin
		
		if [ $? -ne 0 ]; then
			log_err "----------下载 ISGX 驱动失败----------"
			exit 1
		fi

		log_info "----------为ISGX驱动添加运行权限----------"
		chmod +x /tmp/$isgx_driverbin

		log_info "----------安装 ISGX 驱动----------"
		/tmp/$isgx_driverbin

		# if [ ! -c /dev/isgx ]; then
		# 	log_err "----------安装 isgx 驱动失败，请检查主板BIOS----------"
		# 	exit 1
		# else
		# 	yq e -i '.services.phala-pruntime.devices = ["/dev/isgx"]' $installdir/docker-compose.yml
		# fi

		log_info "----------删除临时文件----------"
		rm /tmp/$isgx_driverbin
	# elif [ -L /dev/sgx/enclave -a -L /dev/sgx/provision -a -c /dev/sgx_enclave -a -c /dev/sgx_provision ]; then
	# 	yq e -i '.services.phala-pruntime.devices = ["/dev/sgx_enclave","/dev/sgx_provision","/dev/sgx/enclave","/dev/sgx/provision"]' $installdir/docker-compose.yml
	# else
	# 	yq e -i '.services.phala-pruntime.devices = ["/dev/sgx_enclave","/dev/sgx_provision"]' $installdir/docker-compose.yml
	fi

	log_success "----------删除临时文件----------"
	rm /tmp/$dcap_driverbin
}

install_dcap()
{
	remove_dirver
	log_info "----------下载 DCAP 驱动----------"
	wget $dcap_driverurl -O /tmp/$dcap_driverbin

	if [ $? -ne 0 ]; then
		log_err "----------下载 DCAP 驱动失败----------"
		exit 1
	fi

	log_info "----------添加运行权限----------"
	chmod +x /tmp/$dcap_driverbin

	log_info "----------安装DCAP驱动----------"
	/tmp/$dcap_driverbin

	# if [ ! -c /dev/sgx_enclave -a ! -c /dev/sgx_provision ]; then
	# 	log_err "----------安装DCAP驱动失败----------"
	# 	exit 1
	# elif [ -L /dev/sgx/enclave -a -L /dev/sgx/provision -a -c /dev/sgx_enclave -a -c /dev/sgx_provision ]; then
	# 	yq e -i '.services.phala-pruntime.devices = ["/dev/sgx_enclave","/dev/sgx_provision","/dev/sgx/enclave","/dev/sgx/provision"]' $installdir/docker-compose.yml
	# else
	# 	yq e -i '.services.phala-pruntime.devices = ["/dev/sgx_enclave","/dev/sgx_provision"]' $installdir/docker-compose.yml
	# fi

	log_success "----------删除临时文件----------"
	rm /tmp/$dcap_driverbin
}

install_isgx()
{
	remove_dirver
	log_info "----------下载 isgx 驱动----------"
	wget $isgx_driverurl -O /tmp/$isgx_driverbin
	
	if [ $? -ne 0 ]; then
		log_err "----------下载 isgx 驱动失败----------"
		exit 1
	fi

	log_info "----------添加运行权限----------"
	chmod +x /tmp/$isgx_driverbin

	log_info "----------安装 isgx 驱动----------"
	/tmp/$isgx_driverbin

	# if [! -c /dev/isgx ]; then
	# 	log_err "----------安装 isgx 驱动失败----------"
	# 	exit 1
	# else
	# 	yq e -i '.services.phala-pruntime.devices = ["/dev/isgx"]' $installdir/docker-compose.yml
	# fi

	log_success "----------删除临时文件----------"
	rm /tmp/$isgx_driverbin
}

if [ $(lsb_release -r | grep -o "[0-9]*\.[0-9]*") == "18.04" ]; then
	dcap_driverurl=$(awk -F '=' 'NR==11 {print $2}' $installdir/.env)
	dcap_driverbin=$(awk -F '/' 'NR==11 {print $NF}' $installdir/.env)
	isgx_driverurl=$(awk -F '=' 'NR==13 {print $2}' $installdir/.env)
	isgx_driverbin=$(awk -F '/' 'NR==13 {print $NF}' $installdir/.env)
elif [ $(lsb_release -r | grep -o "[0-9]*\.[0-9]*") = "20.04" ]; then
	dcap_driverurl=$(awk -F '=' 'NR==12 {print $2}' $installdir/.env)
	dcap_driverbin=$(awk -F '/' 'NR==12 {print $NF}' $installdir/.env)
	isgx_driverurl=$(awk -F '=' 'NR==14 {print $2}' $installdir/.env)
	isgx_driverbin=$(awk -F '/' 'NR==14 {print $NF}' $installdir/.env)
else
	log_err "----------系统版本不支持----------"
	exit 1
fi

install()
{
	case "$1" in
		"")
			install_depenencies
			install_driver
			;;
		dcap)
			install_dcap
			;;
		isgx)
			install_isgx
			;;
		*)
			log_err "----------参数错误----------"
			exit 1
			;;
	esac

	if [ -c /dev/sgx_enclave -a -c /dev/sgx_provision ]; then
		yq e -i '.services.phala-pruntime.devices = ["/dev/sgx_enclave","/dev/sgx_provision"]' $installdir/docker-compose.yml
	elif [ -L /dev/sgx/enclave -a -L /dev/sgx/provision -a -c /dev/sgx_enclave -a -c /dev/sgx_provision ]; then
		yq e -i '.services.phala-pruntime.devices = ["/dev/sgx_enclave","/dev/sgx_provision","/dev/sgx/enclave","/dev/sgx/provision"]' $installdir/docker-compose.yml
	elif [ -c /dev/isgx ]; then
		yq e -i '.services.phala-pruntime.devices = ["/dev/isgx"]' $installdir/docker-compose.yml
	fi

	exit 0
}
