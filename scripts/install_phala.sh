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
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
    add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
    apt-get install -y docker-ce docker-ce-cli containerd.io jq
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
    local driverbin=sgx_linux_x64_driver_1.36.2.bin
    local driverurl=https://download.01.org/intel-sgx/sgx-dcap/1.9/linux/distro/ubuntu18.04-server/sgx_linux_x64_driver_1.36.2.bin
    wget $driverurl

    if [ $? -ne 0 ]; then
        log_err "----------Download dcap dirver failed----------"
        exit 1
    fi

    log_info "----------Give dcap driver executable permission----------"
    chmod +x $driverbin

    log_info "----------Installing dcap driver----------"
    ./$driverbin

    local res_dcap=$(ls /dev | grep sgx)
    if [ x"$res_dcap" == x"" ]; then
        log_err "----------Install dcap dirver bin failed----------"
        remove_dirver
        log_info "----------Download isgx driver----------"
        driverbin=sgx_linux_x64_driver_2.6.0_b0a445b.bin
        driverurl=https://download.01.org/intel-sgx/sgx-linux/2.11/distro/ubuntu18.04-server/sgx_linux_x64_driver_2.6.0_b0a445b.bin
        wget $driverurl
        
        if [ $? -ne 0 ]; then
            log_err "----------Download isgx dirver failed----------"
            exit 1
        fi

        log_info "----------Give isgx driver executable permission----------"
        chmod +x $driverbin

        log_info "----------Installing isgx driver----------"
        ./$driverbin

        local res_sgx=$(ls /dev | grep isgx)
        if [ x"$res_sgx" == x"" ]; then
            log_err "----------Install isgx dirver bin failed----------"
            exit 1
        fi

        log_info "----------Clean resource----------"
        rm $driverbin
    fi

    log_success "----------Clean resource----------"
    rm $driverbin
}

install_dcap()
{
    remove_dirver
    log_info "----------Download dcap driver----------"
    local driverbin=sgx_linux_x64_driver_1.36.2.bin
    local driverurl=https://download.01.org/intel-sgx/sgx-dcap/1.9/linux/distro/ubuntu18.04-server/sgx_linux_x64_driver_1.36.2.bin
    wget $driverurl

    if [ $? -ne 0 ]; then
        log_err "----------Download isgx dirver failed----------"
        exit 1
    fi

    log_info "----------Give dcap driver executable permission----------" 
    chmod +x $driverbin

    log_info "----------Installing dcap driver----------"
    ./$driverbin

    local res_dcap=$(ls /dev | grep sgx)
    if [ x"$res_sgx" == x"" ]; then
        log_err "----------Install dcap dirver bin failed----------"
        exit 1
    fi

    log_success "----------Clean resource----------"
    rm $driverbin
}

install_isgx()
{
    remove_dirver
    log_info "----------Download isgx driver----------"
    local driverbin=sgx_linux_x64_driver_2.6.0_b0a445b.bin
    local driverurl=https://download.01.org/intel-sgx/sgx-linux/2.11/distro/ubuntu18.04-server/sgx_linux_x64_driver_2.6.0_b0a445b.bin
    wget $driverurl
    
    if [ $? -ne 0 ]; then
        log_err "----------Download isgx dirver failed----------"
        exit 1
    fi

    log_info "----------Give isgx driver executable permission----------"
    chmod +x $driverbin

    log_info "----------Installing isgx driver----------"
    ./$driverbin

    local res_sgx=$(ls /dev | grep isgx)
    if [ x"$res_sgx" == x"" ]; then
        log_err "----------Install isgx dirver bin failed----------"
        exit 1
    fi

    log_success "----------Clean resource----------"
    rm $driverbin
}

install()
{
    case "$1" in
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
