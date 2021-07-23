#!/bin/bash

install_depenencies()
{
	log_info "----------Apt update----------"
	apt-get update
	if [ $? -ne 0 ]; then
		log_err "Apt update failed"
		exit 1
	fi

	log_info "----------Install depenencies----------"
	apt-get install -y jq curl wget unzip zip
	curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
	add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
	apt-get install -y docker-ce docker-ce-cli containerd.io dkms
	curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/bin/docker-compose
	chmod +x /usr/bin/docker-compose
	curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
	if [ $? -ne 0 ]; then
		log_err "Install depenencies failed"
		exit 1
	fi
	usermod -aG docker $USER
}

remove_dirver()
{
	log_info "----------Remove dcap/isgx driver----------"
	local contents26=$(cat $installdir/docker-compose.yml|awk 'NR==26')
	local contents27=$(cat $installdir/docker-compose.yml|awk 'NR==27')
	if [ ! -z $contents26 ]&&[ "$contents26" != '  environment: ' ]; then
		sed -i "26c \ " $installdir/docker-compose.yml
	fi
	
	if [ ! -z $contents27 ]&&[ "$contents27" != '  environment: ' ]&&[ "$contents27" != '   - EXTRA_OPTS=--cores=${CORES}' ]
		sed -i "27c \ " $installdir/docker-compose.yml
	fi

	local res_isgx=$(ls /dev | grep isgx)
	local res_sgx=$(ls /dev | grep sgx)
	if [ x"$res_isgx" == x"isgx" ] || [ x"$res_sgx" == x"sgx" ]; then
		/opt/intel/sgxdriver/uninstall.sh
		sed -i "26a \ " $installdir/docker-compose.yml
		sed -i "27a \ " $installdir/docker-compose.yml
		if [ $? -ne 0 ]; then
			log_info "----------Remove dcap/isgx driver failed----------"
			exit 1
		fi
	fi
}

install_driver()
{
	remove_dirver
	log_info "----------Download dcap driver----------"
	wget $dcap_driverurl

	if [ $? -ne 0 ]; then
		log_err "----------Download dcap dirver failed----------"
		exit 1
	fi

	log_info "----------Give dcap driver executable permission----------"
	chmod +x $dcap_driverbin

	log_info "----------Installing dcap driver----------"
	./$dcap_driverbin

	local res_dcap=$(ls /dev | grep sgx)
	if [ x"$res_dcap" == x"" ]; then
		log_err "----------Install dcap dirver bin failed----------"
		remove_dirver
		log_info "----------Download isgx driver----------"
		wget $isgx_driverurl
		
		if [ $? -ne 0 ]; then
			log_err "----------Download isgx dirver failed----------"
			exit 1
		fi

		log_info "----------Give isgx driver executable permission----------"
		chmod +x $isgx_driverbin

		log_info "----------Installing isgx driver----------"
		./$isgx_driverbin

		local res_sgx=$(ls /dev | grep isgx)
		if [ x"$res_sgx" == x"" ]; then
			log_err "----------Install isgx dirver bin failed----------"
			exit 1
		else
			sed -i "26a \   - /dev/isgx" $installdir/docker-compose.yml
		fi

		log_info "----------Clean resource----------"
		rm $isgx_driverbin
	else
		sed -i "26a \   - /dev/sgx/enclave" $installdir/docker-compose.yml
		sed -i "27a \   - /dev/sgx/provision" $installdir/docker-compose.yml
	fi

	log_success "----------Clean resource----------"
	rm $dcap_driverbin
}

install_dcap()
{
	remove_dirver
	log_info "----------Download dcap driver----------"
	wget $dcap_driverurl

	if [ $? -ne 0 ]; then
		log_err "----------Download isgx dirver failed----------"
		exit 1
	fi

	log_info "----------Give dcap driver executable permission----------" 
	chmod +x $dcap_driverbin

	log_info "----------Installing dcap driver----------"
	./$dcap_driverbin

	local res_dcap=$(ls /dev | grep sgx)
	if [ x"$res_dcap" == x"" ]; then
		log_err "----------Install dcap dirver bin failed----------"
		exit 1
	else
		sed -i "26a \   - /dev/sgx/enclave" $installdir/docker-compose.yml
		sed -i "27a \   - /dev/sgx/provision" $installdir/docker-compose.yml
	fi

	log_success "----------Clean resource----------"
	rm $dcap_driverbin
}

install_isgx()
{
	remove_dirver
	log_info "----------Download isgx driver----------"
	wget $isgx_driverurl
	
	if [ $? -ne 0 ]; then
		log_err "----------Download isgx dirver failed----------"
		exit 1
	fi

	log_info "----------Give isgx driver executable permission----------"
	chmod +x $isgx_driverbin

	log_info "----------Installing isgx driver----------"
	./$isgx_driverbin

	local res_sgx=$(ls /dev | grep isgx)
	if [ x"$res_sgx" == x"" ]; then
		log_err "----------Install isgx dirver bin failed----------"
		exit 1
	else
		sed -i "26a \   - /dev/isgx" $installdir/docker-compose.yml
	fi

	log_success "----------Clean resource----------"
	rm $isgx_driverbin
}

install()
{
	release=$(lsb_release -r | grep -o "[0-9]*\.[0-9]*")
	if [ x"$release" = x"18.04" ]; then
		dcap_driverbin=sgx_linux_x64_driver_1.36.2.bin
		dcap_driverurl=https://download.01.org/intel-sgx/sgx-dcap/1.9/linux/distro/ubuntu18.04-server/sgx_linux_x64_driver_1.36.2.bin
		isgx_driverbin=sgx_linux_x64_driver_2.11.0_2d2b795.bin
		isgx_driverurl=https://download.01.org/intel-sgx/latest/linux-latest/distro/ubuntu18.04-server/sgx_linux_x64_driver_2.11.0_2d2b795.bin
	elif [ x"$release" = x"20.04" ]; then
		dcap_driverbin=sgx_linux_x64_driver_1.36.2.bin
		dcap_driverurl=https://download.01.org/intel-sgx/sgx-dcap/1.9/linux/distro/ubuntu20.04-server/sgx_linux_x64_driver_1.36.2.bin
		isgx_driverbin=sgx_linux_x64_driver_2.11.0_2d2b795.bin
		isgx_driverurl=https://download.01.org/intel-sgx/latest/linux-latest/distro/ubuntu20.04-server/sgx_linux_x64_driver_2.11.0_2d2b795.bin
	else
		log_err "----------The system does not support----------"
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
			log_err "----------Parameter error----------"
			exit 1
			;;
	esac

	exit 0
}
