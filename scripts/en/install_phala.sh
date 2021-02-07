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
	apt-get install -y jq curl wget unzip
	curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
	add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
	apt-get install -y docker-ce docker-ce-cli containerd.io dkms
	if [ $? -ne 0 ]; then
		log_err "Install depenencies failed"
		exit 1
	fi
	usermod -aG docker $USER
}

download_docker_images()
{
	log_info "----------Download phala docker images----------"
	local res=0

	docker pull phalanetwork/phala-poc3-node
	res=$(($?|$res))
	docker pull phalanetwork/phala-poc3-pruntime
	res=$(($?|$res))
	docker pull phalanetwork/phala-poc3-phost
	res=$(($?|$res))

	if [ $res -ne 0 ]; then
		log_err "----------Download docker images failed----------"
		exit 1
	fi
}

remove_dirver()
{
	log_info "----------Remove dcap/isgx driver----------"
	local res_isgx=$(ls /dev | grep isgx)
	local res_sgx=$(ls /dev | grep sgx)
	if [ x"$res_isgx" == x"isgx" ] || [ x"$res_sgx" == x"sgx" ]; then
		/opt/intel/sgxdriver/uninstall.sh
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
		fi

		log_info "----------Clean resource----------"
		rm $isgx_driverbin
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
		isgx_driverbin=sgx_linux_x64_driver_2.11.0_4505f07.bin
		isgx_driverurl=https://download.01.org/intel-sgx/latest/linux-latest/distro/ubuntu18.04-server/sgx_linux_x64_driver_2.11.0_4505f07.bin
	elif [ x"$release" = x"20.04" ]; then
		dcap_driverbin=sgx_linux_x64_driver_1.36.2.bin
		dcap_driverurl=https://download.01.org/intel-sgx/sgx-dcap/1.9/linux/distro/ubuntu20.04-server/sgx_linux_x64_driver_1.36.2.bin
		isgx_driverbin=sgx_linux_x64_driver_2.11.0_4505f07.bin
		isgx_driverurl=https://download.01.org/intel-sgx/latest/linux-latest/distro/ubuntu20.04-server/sgx_linux_x64_driver_2.11.0_4505f07.bin
	else
		log_err "----------The system does not support----------"
		exit 1
	fi

	case "$1" in
		"")
			install_depenencies
			download_docker_images
			install_driver
			;;
		init)
			install_depenencies
			download_docker_images
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
