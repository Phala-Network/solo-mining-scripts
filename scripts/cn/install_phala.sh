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
	apt-get install -y jq curl wget unzip zip
	curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
	add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
	apt-get install -y docker-ce docker-ce-cli containerd.io dkms
	curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/bin/docker-compose
	chmod +x /usr/bin/docker-compose
	curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
	apt-get install -y nodejs
	if [ $? -ne 0 ]; then
		log_err "安装依赖失败"
		exit 1
	fi
	usermod -aG docker $USER
}

remove_dirver()
{
	log_info "----------删除旧版本 dcap/isgx 驱动----------"
	local contents26=$(cat $installdir/docker-compose.yml|awk 'NR==26')
	local contents27=$(cat $installdir/docker-compose.yml|awk 'NR==27')
	if [ ! -z $contents26 ]&&[ "$contents26" != '  environment: ' ]; then
		sed -i "26c \ " $installdir/docker-compose.yml
	fi
	
	if [ ! -z "$contents27" ]&&[ "$contents27" != '  environment: ' ]&&[ "$contents27" != '   - EXTRA_OPTS=--cores=${CORES}' ]; then
		sed -i "27c \ " $installdir/docker-compose.yml
	fi

	local res_isgx=$(ls /dev | grep isgx)
	local res_sgx=$(ls /dev | grep sgx)
	if [ x"$res_isgx" == x"isgx" ] || [ x"$res_sgx" == x"sgx" ]; then
		/opt/intel/sgxdriver/uninstall.sh
		if [ $? -ne 0 ]; then
			log_info "----------删除旧版本 dcap/isgx 驱动失败----------"
			exit 1
		fi
	fi
}

install_driver()
{
	remove_dirver
	log_info "----------下载 DCAP 驱动----------"
	wget $dcap_driverurl

	if [ $? -ne 0 ]; then
		log_err "----------下载 DCAP 驱动失败----------"
		exit 1
	fi

	log_info "----------添加运行权限----------"
	chmod +x $dcap_driverbin

	log_info "----------尝试安装DCAP驱动----------"
	./$dcap_driverbin

	local res_dcap=$(ls /dev | grep sgx)
	if [ x"$res_dcap" == x"" ]; then
		log_err "----------安装DCAP驱动失败，尝试安装isgx驱动----------"
		remove_dirver
		log_info "----------下载 isgx 驱动----------"
		wget $isgx_driverurl
		
		if [ $? -ne 0 ]; then
			log_err "----------下载 isgx 驱动失败----------"
			exit 1
		fi

		log_info "----------添加运行权限----------"
		chmod +x $isgx_driverbin

		log_info "----------安装 isgx 驱动----------"
		./$isgx_driverbin

		local res_sgx=$(ls /dev | grep isgx)
		if [ x"$res_sgx" == x"" ]; then
			log_err "----------安装 isgx 驱动失败，请检查主板BIOS----------"
			exit 1
		else
			sed -i "26a \   - /dev/isgx" $installdir/docker-compose.yml
		fi

		log_info "----------删除临时文件----------"
		rm $isgx_driverbin
	else
		sed -i "26a \   - /dev/sgx/enclave" $installdir/docker-compose.yml
		sed -i "27a \   - /dev/sgx/provision" $installdir/docker-compose.yml
	fi

	log_success "----------删除临时文件----------"
	rm $dcap_driverbin
}

install_dcap()
{
	remove_dirver
	log_info "----------下载 DCAP 驱动----------"
	wget $dcap_driverurl

	if [ $? -ne 0 ]; then
		log_err "----------下载 DCAP 驱动失败----------"
		exit 1
	fi

	log_info "----------添加运行权限----------"
	chmod +x $dcap_driverbin

	log_info "----------安装DCAP驱动----------"
	./$dcap_driverbin

	local res_dcap=$(ls /dev | grep sgx)
	if [ x"$res_dcap" == x"" ]; then
		log_err "----------安装DCAP驱动失败----------"
		exit 1
	else
		sed -i "26a \   - /dev/sgx/enclave" $installdir/docker-compose.yml
		sed -i "27a \   - /dev/sgx/provision" $installdir/docker-compose.yml
	fi

	log_success "----------删除临时文件----------"
	rm $dcap_driverbin
}

install_isgx()
{
	remove_dirver
	log_info "----------下载 isgx 驱动----------"
	wget $isgx_driverurl
	
	if [ $? -ne 0 ]; then
		log_err "----------下载 isgx 驱动失败----------"
		exit 1
	fi

	log_info "----------添加运行权限----------"
	chmod +x $isgx_driverbin

	log_info "----------安装 isgx 驱动----------"
	./$isgx_driverbin

	local res_sgx=$(ls /dev | grep isgx)
	if [ x"$res_sgx" == x"" ]; then
		log_err "----------安装 isgx 驱动失败----------"
		exit 1
	else
		sed -i "26a \   - /dev/isgx" $installdir/docker-compose.yml
	fi

	log_success "----------删除临时文件----------"
	rm $isgx_driverbin
}

install()
{
	release=$(lsb_release -r | grep -o "[0-9]*\.[0-9]*")
	if [ x"$release" = x"18.04" ]; then
		dcap_driverbin=sgx_linux_x64_driver_1.41.bin
		dcap_driverurl=https://download.01.org/intel-sgx/latest/dcap-latest/linux/distro/ubuntu18.04-server/sgx_linux_x64_driver_1.41.bin
		isgx_driverbin=sgx_linux_x64_driver_2.11.0_2d2b795.bin
		isgx_driverurl=https://download.01.org/intel-sgx/latest/linux-latest/distro/ubuntu18.04-server/sgx_linux_x64_driver_2.11.0_2d2b795.bin
	elif [ x"$release" = x"20.04" ]; then
		dcap_driverbin=sgx_linux_x64_driver_1.41.bin
		dcap_driverurl=https://download.01.org/intel-sgx/latest/dcap-latest/linux/distro/ubuntu20.04-server/sgx_linux_x64_driver_1.41.bin
		isgx_driverbin=sgx_linux_x64_driver_2.11.0_2d2b795.bin
		isgx_driverurl=https://download.01.org/intel-sgx/latest/linux-latest/distro/ubuntu20.04-server/sgx_linux_x64_driver_2.11.0_2d2b795.bin
	else
		log_err "----------系统版本不支持----------"
		exit 1
	fi

	case "$1" in
		"")
			install_depenencies
			config_set_all
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

	exit 0
}
