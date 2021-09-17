#!/bin/bash

function install_depenencies()
{
	log_info "----------Apt update----------"
	apt-get update
	if [ $? -ne 0 ]; then
		log_err "Apt update failed"
		exit 1
	fi

	log_info "----------Install depenencies----------"
	for i in `seq 0 4`; do
		for package in jq curl wget unzip zip docker docker-compose node yq dkms; do
			if ! type $package > /dev/null; then
				case $package in
					jq|curl|wget|unzip|zip|dkms)
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
		if type jq curl wget unzip zip docker docker-compose node yq dkms > /dev/null; then
			break
		else
			log_err "----------Failed to install depenencies, please to check install logs!----------"
			exit 1
		fi
	done
}

function remove_dirver()
{
	if [ -f /opt/intel/sgxdriver/uninstall.sh ]; then
		log_info "----------Remove dcap/isgx driver----------"
		/opt/intel/sgxdriver/uninstall.sh
	fi
}

function install_dcap()
{
	log_info "----------Download dcap driver----------"
	for i in `seq 0 4`; do
		wget $dcap_driverurl -O /tmp/$dcap_driverbin
		if [ $? -ne 0 ]; then
			log_err "----------Download isgx dirver failed, try again!----------"
		else
			break
		fi
	done

	if [ -f /tmp/$dcap_driverbin ]; then
		log_info "----------Give dcap driver executable permission----------" 
		chmod +x /tmp/$dcap_driverbin
	else
		log_err "----------The DCAP driver was not successfully downloaded, please check your network!----------"
		exit 1
	fi

	log_info "----------Installing dcap driver----------"
	/tmp/$dcap_driverbin
	if [ $? -ne 0 ]; then
		log_err "----------Failed to install the DCAP driver, please check the driver installation logs!----------"
		exit 1
	else
		log_success "----------Delete temporary files----------"
		rm /tmp/$dcap_driverbin
	fi

	return 0
}

function install_isgx()
{
	log_info "----------Download isgx driver----------"
	for i in `seq 0 4`; do
		wget $isgx_driverurl -O /tmp/$isgx_driverbin
		if [ $? -ne 0 ]; then
			log_err "----------Download isgx dirver failed----------"
		else
			break
		fi
	done

	if [ -f /tmp/$isgx_driverbin ]; then
		log_info "----------Give isgx driver executable permission----------"
		chmod +x /tmp/$isgx_driverbin
	else
		log_err "----------The isgx driver was not successfully downloaded, please check your network!----------"
		exit 1
	fi

	log_info "----------Installing isgx driver----------"
	/tmp/$isgx_driverbin
	if [ $? -ne 0 ]; then
		log_err "----------Failed to install the isgx driver, please check the driver installation logs!----------"
		exit 1
	else
		log_success "----------Delete temporary files----------"
		rm /tmp/$isgx_driverbin
	fi

	return 0
}

function install_driver()
{
	remove_dirver
	install_dcap
	if [ $? -ne 0 ]; then
		install_isgx
		if [ $? -ne 0 ]; then
			log_err "----------Failed to install the DCAP and isgx driver, please check the driver installation logs!----------"
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

	if [ -L /dev/sgx/enclave ] && [ -L /dev/sgx/provision ] && [ -c /dev/sgx_enclave ] && [ -c /dev/sgx_provision ] && [ ! -c /dev/isgx ]; then
		log_info "----------Your device exists: /dev/sgx/enclave /dev/sgx/provision /dev/sgx_enclave /dev/sgx_provision is related to the DCAP driver, all have been added to phala-pruntime!----------"
		yq e -i '.services.phala-pruntime.devices = ["/dev/sgx/enclave","/dev/sgx/provision","/dev/sgx_enclave","/dev/sgx_provision"]' $installdir/docker-compose.yml
	elif [ ! -L /dev/sgx/enclave ] && [ -L /dev/sgx/provision ] && [ -c /dev/sgx_enclave ] && [ -c /dev/sgx_provision ] && [ ! -c /dev/isgx ]; then
		log_info "----------Your device exists: /dev/sgx/provision /dev/sgx_enclave /dev/sgx_provision is related to the DCAP driver, all have been added to phala-pruntime!----------"
		yq e -i '.services.phala-pruntime.devices = ["/dev/sgx/provision","/dev/sgx_enclave","/dev/sgx_provision"]' $installdir/docker-compose.yml
	elif [ ! -L /dev/sgx/enclave ] && [ ! -L /dev/sgx/provision ] && [ -c /dev/sgx_enclave ] && [ -c /dev/sgx_provision ] && [ ! -c /dev/isgx ]; then
		log_info "----------Your device exists: /dev/sgx_enclave /dev/sgx_provision is related to the DCAP driver, all have been added to phala-pruntime!----------"
		yq e -i '.services.phala-pruntime.devices = ["/dev/sgx_enclave","/dev/sgx_provision"]' $installdir/docker-compose.yml
	elif [ ! -L /dev/sgx/enclave ] && [ ! -L /dev/sgx/provision ] && [ ! -c /dev/sgx_enclave ] && [ -c /dev/sgx_provision ] && [ ! -c /dev/isgx ]; then
		log_info "----------Your device exists: /dev/sgx_provision is related to the DCAP driver, all have been added to phala-pruntime!----------"
		yq e -i '.services.phala-pruntime.devices = ["/dev/sgx_provision"]' $installdir/docker-compose.yml
	elif [ ! -L /dev/sgx/enclave ] && [ ! -L /dev/sgx/provision ] && [ ! -c /dev/sgx_enclave ] && [ ! -c /dev/sgx_provision ] && [ -c /dev/isgx ]; then
		log_info "----------Your device exists: /dev/isgx is related to the isgx driver, all have been added to phala-pruntime!----------"
		yq e -i '.services.phala-pruntime.devices = ["/dev/isgx"]' $installdir/docker-compose.yml
	else
		log_info "----------The DCAP/isgx driver file was not found, please check the driver installation logs!----------"
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
	log_err "----------The system does not support, phala currently only supports Ubuntu 18.04/Ubuntu 20.04----------"
	exit 1
fi
