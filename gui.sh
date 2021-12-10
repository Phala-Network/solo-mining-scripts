#!/bin/bash

function info_entry_question()
{
    if (whiptail --title "Phala Miner Installation" --yesno "This will install a Phala Miner on your System do you wish to proceed?" 8 78); then
        break

    else
        echo "You aborted the installation process, exit status was $?."
        exit 1
fi
}


function download_script()
{
    # downloading the solo mining script & executing it
    sudo apt update && sudo apt upgrade -y && sudo apt autoremove -y
    sudo apt install wget unzip
    cd ~
    wget https://github.com/Phala-Network/solo-mining-scripts/archive/refs/heads/main.zip
    unzip main.zip
    rm -r main.zip #cleaning up the installation
    cd solo-mining-scripts-main/ #note this depends on your current directory
    chmod +x install.sh
    sudo ./install.sh en
}

function enable_SGX()
{
    # add error handling for SGX
    sudo chmod +x sgx_enable
    if [ sudo ./sgx_enable -eq 0 ]; then
			echo success
		elif [ $res -eq 2 ]; then
			echo error
    # enable SGX
}
