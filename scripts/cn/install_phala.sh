#!/bin/bash

function install_depenencies()
{
	log_info "----------更新系统源----------"
	apt-get update
	if [ $? -ne 0 ]; then
		log_err "系统源更新失败"
		exit 1
	fi

	log_info "----------安装依赖----------"
	for i in `seq 0 4`; do
		for package in jq curl wget unzip zip docker docker-compose node yq dkms bc; do
			if ! type $package > /dev/null 2>&1; then
				case $package in
					jq|curl|wget|unzip|zip|dkms|bc)
						apt-get install -y $package
						;;
					docker)
						curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
						add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
						apt-get install -y docker-ce docker-ce-cli containerd.io
						usermod -aG docker $USER
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
		if type jq curl wget unzip zip docker docker-compose node yq dkms bc; then break;fi
	done
}

function remove_dirver()
{
	if [ -f /opt/intel/sgxdriver/uninstall.sh ]; then
		log_info "----------删除旧版本 dcap/isgx 驱动----------"
		/opt/intel/sgxdriver/uninstall.sh
	fi
}

function install_dcap()
{
	log_info "----------下载 DCAP 驱动----------"
	for i in `seq 0 4`; do
		wget $dcap_driverurl -O /tmp/$dcap_driverbin
		if [ $? -ne 0 ]; then
			log_err "----------下载 DCAP 驱动失败，重新下载！----------"
		else
			break
		fi
	done

	if [ -f /tmp/$dcap_driverbin ]; then
		log_info "----------添加运行权限----------"
		chmod +x /tmp/$dcap_driverbin
	else
		log_err "----------未成功下载 DCAP 驱动，请检查您的网络！----------"
		exit 1
	fi

	log_info "----------安装DCAP驱动----------"
	/tmp/$dcap_driverbin
	if [ $? -ne 0 ]; then
		log_err "----------安装DCAP驱动失败，请检查驱动安装日志！----------"
		exit 1
	else
		log_success "----------删除临时文件----------"
		rm /tmp/$dcap_driverbin
	fi

	return 0
}

function install_isgx()
{
	log_info "----------下载 isgx 驱动----------"
	for i in `seq 0 4`; do
		wget $isgx_driverurl -O /tmp/$isgx_driverbin
		if [ $? -ne 0 ]; then
			log_err "----------下载 isgx 驱动失败，重新下载！----------"
		else
			break
		fi
	done

	if [ -f /tmp/$dcap_driverbin ]; then
		log_info "----------添加运行权限----------"
		chmod +x /tmp/$isgx_driverbin
	else
		log_err "----------未成功下载 isgx 驱动，请检查您的网络！----------"
		exit 1
	fi

	log_info "----------安装 isgx 驱动----------"
	/tmp/$isgx_driverbin
	if [ $? -ne 0 ]; then
		log_err "----------安装isgx驱动失败，请检查驱动安装日志！----------"
		exit 1
	else
		log_success "----------删除临时文件----------"
		rm /tmp/$isgx_driverbin
	fi

	return 0
}

function install_driver()
{
	remove_dirver
	install_dcap
	if [ $? -ne 0 ]; then
		log_err "----------尝试安装isgx驱动！----------"
		install_isgx
		if [ $? -ne 0 ]; then
			log_err "----------安装DCAP/isgx驱动均失败，请检查安装日志！----------"
			exit 1
		fi
	fi
}

function install()
{
	case "$1" in
		"")
			install_depenencies
			install_driver
			config set
			;;
		dcap)
			install_dcap
			;;
		isgx)
			install_isgx
			;;
		*)
			phala_help
			exit 1
			;;
	esac

	if [ -L /dev/sgx/enclave ]&&[ -L /dev/sgx/provision ]&&[ -c /dev/sgx_enclave ]&&[ -c /dev/sgx_provision ]&&[ ! -c /dev/isgx ]; then
		log_info "----------您的设备存在：/dev/sgx/enclave /dev/sgx/provision /dev/sgx_enclave /dev/sgx_provision 与DCAP驱动有关，已全部添加到phala-pruntime！----------"
		yq e -i '.services.phala-pruntime.devices = ["/dev/sgx/enclave","/dev/sgx/provision","/dev/sgx_enclave","/dev/sgx_provision"]' $installdir/docker-compose.yml
	elif [ ! -L /dev/sgx/enclave ]&&[ -L /dev/sgx/provision ]&&[ -c /dev/sgx_enclave ]&&[ -c /dev/sgx_provision ]&&[ ! -c /dev/isgx ]; then
		log_info "----------您的设备存在：/dev/sgx/provision /dev/sgx_enclave /dev/sgx_provision 与DCAP驱动有关，已全部添加到phala-pruntime！----------"
		yq e -i '.services.phala-pruntime.devices = ["/dev/sgx/provision","/dev/sgx_enclave","/dev/sgx_provision"]' $installdir/docker-compose.yml
	elif [ ! -L /dev/sgx/enclave ]&&[ ! -L /dev/sgx/provision ]&&[ -c /dev/sgx_enclave ]&&[ -c /dev/sgx_provision ]&&[ ! -c /dev/isgx ]; then
		log_info "----------您的设备存在：/dev/sgx_enclave /dev/sgx_provision 与DCAP驱动有关，已全部添加到phala-pruntime！----------"
		yq e -i '.services.phala-pruntime.devices = ["/dev/sgx_enclave","/dev/sgx_provision"]' $installdir/docker-compose.yml
	elif [ ! -L /dev/sgx/enclave ]&&[ ! -L /dev/sgx/provision ]&&[ ! -c /dev/sgx_enclave ]&&[ -c /dev/sgx_provision ]&&[ ! -c /dev/isgx ]; then
		log_info "----------您的设备存在：/dev/sgx_provision 与DCAP驱动有关，已全部添加到phala-pruntime！----------"
		yq e -i '.services.phala-pruntime.devices = ["/dev/sgx_provision"]' $installdir/docker-compose.yml
	elif [ ! -L /dev/sgx/enclave ]&&[ ! -L /dev/sgx/provision ]&&[ ! -c /dev/sgx_enclave ]&&[ ! -c /dev/sgx_provision ]&&[ -c /dev/isgx ]; then
		log_info "----------您的设备存在：/dev/isgx 与isgx驱动有关，已全部添加到phala-pruntime！----------"
		yq e -i '.services.phala-pruntime.devices = ["/dev/isgx"]' $installdir/docker-compose.yml
	else
		log_info "----------未找到驱动文件，请检查驱动安装日志！----------"
		exit 1
	fi
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
	log_err "----------系统版本不支持，phala目前仅支持Ubuntu 18.04/Ubuntu 20.04----------"
	exit 1
fi
