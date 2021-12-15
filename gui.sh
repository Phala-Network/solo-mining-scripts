#!/bin/bash

installdir=/opt/phala
scriptdir=$installdir/scripts

set -a 

function info_entry_question()
{
    if (whiptail --title "Phala Miner Installation" --yesno "This will install a Phala Miner on your System do you wish to proceed? \nAny existing Phala Miner installations will be overwritten" 8 78); then
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
    # change for main below
    # Progress Bar for download
    wget --progress=dot 'https://github.com/Phala-Network/solo-mining-scripts/archive/refs/heads/improvement-test.zip' 2>&1 | sed -un 's/.* \([0-9]\+\)% .*/\1/p' | whiptail --gauge "Download" 7 50 0
    yes | unzip improvement-test.zip
    rm -r improvement-test.zip #cleaning up the installation
    cd solo-mining-scripts-improvement-test/ #note this depends on your current directory
    chmod +x install.sh
    sudo yes | sudo ./install.sh en
}

function enable_SGX()
{
    cd ~
    cd solo-mining-scripts-improvement-test/
    sudo chmod +x sgx_enable
    sudo ./sgx_enable
    if [ $? -eq 0 ]; then
        whiptail --title "Phala Miner Intel© SGX" --msgbox "Intel© SGX Successfully Activated\nHit OK to proceed setting up your drivers." 8 78
	else 
		whiptail --title "Phala Miner Intel© SGX" --msgbox "Error Activating Intel© SGX. The installation was aborted. \nPlease check wiki.phala.network for more info.\nHit OK to proceed." 8 78
        set -a
        exit 1

    # enable SGX
fi
}

function install_SGX_drivers()
{
    sudo phala sgx-test
}

function getting_miner_ready()
{   
    sudo phala install
    if [ $? -eq 0 ]; then
        {           
                i="0"
                while (true)
                do
                    proc=$(ps aux | grep -v grep | grep -e "phala install")
                    if [[ "$proc" == "" ]]; then break; fi
                    # Sleep for a longer period if the process takes too long 
                    sleep 1
                    echo $i
                    i=$(expr $i + 1)
                done
                # If it is done then display 100%
                echo 100
                # Give it some time to display the progress to the user.
                sleep 2
        } | whiptail --title "Intel© SGX Driver Installation" --gauge "Phala Miner Driver Check" 8 78 0
    else
        whiptail --title "Phala Miner Installation Error" --msgbox "Error Installing the Miner. The installation was aborted. \nPlease check the logs displayed in the terminal.\nwiki.phala.network for more info.\nHit OK to proceed." 8 78
        exit 1
    fi
}

function extracting_snapshot()
{ 
    
    {       tar -xvzf khala-snapshot-210915.tar.gz    
            i="0"
            while (true)
            do
                proc=$(ps aux | grep -v grep | grep -e "tar")
                if [[ "$proc" == "" ]]; then break; fi
                # Sleep for a longer period if the process takes too long 
                sleep 1
                echo $i
                i=$(expr $i + 1)
            done
            # If it is done then display 100%
            echo 100
            # Give it some time to display the progress to the user.
            sleep 2
    } | whiptail --title "Phala Snapshot Extraction" --gauge "Extracting the archive, this will take a while" 8 78 0
}

function snapshot_download()
{
    if (whiptail --title "Phala Miner Snapshot Download" --yesno "This will download a Snapshot to speed up syncing, do you wish to proceed?\nNote: This will take a very long time depening on your network connection" 8 78); then
        # downloading the snapshot with wget & displaying a status bar with whiptail
        wget --progress=dot 'https://storage.googleapis.com/khala-snapshots/khala-snapshot-210915.tar.gz' 2>&1 | sed -un 's/.* \([0-9]\+\)% .*/\1/p' | whiptail --gauge "Download" 7 50 0
        {
        if [ $? -eq 0 ]; then
            whiptail --title "Phala Miner Snapshot Download Succeded" --msgbox "Phala Miner Snapshot successfully downloaded." 8 78
            whiptail --title "Phala Snapshot Extraction" --msgbox "We will now extract the downloaded snapshot. The Extraction Progress will take a while..." 8 78
            extracting_snapshot
            rm -r /var/khala-dev-node/chains
            rm -r /var/khala-dev-node/polkadot
            mv ~/khala-node/chains/ /var/khala-dev-node
            mv ~/khala-node/polkadot/ /var/khala-dev-node
        else
            whiptail --title "Phala Miner Snapshot Download Failed" --msgbox "Phala Miner Snapshot failed to download." 8 78
        fi       
        }
    else
        echo "Skipping the download and snapshot setup."
fi
}

function node_config()
{
    #Miner Name
    exitstatus=$?
    if [ $exitstatus = 0 ]; then
        NODENAME=$(whiptail --inputbox "Enter the desired name of this node.\nNO SPACES!" 8 39 PhalaMiner1 --title "Node Setup" 3>&1 1>&2 2>&3)
        local node_name
		while true ; do
			if [[ $NODENAME =~ \ |\' ]]; then
				printf "The node name cannot contain spaces, please re-enter!\n"
                whiptail --title "ERROR" --msgbox "The node name cannot contain spaces, please re-enter!\nTry again." 8 78
                NODENAME=$(whiptail --inputbox "Enter the desired name of this node.\nNO SPACES!" 8 39 PhalaMiner1 --title "Node Setup" 3>&1 1>&2 2>&3)
			else
				sed -i "7c NODE_NAME=$NODENAME" $installdir/.env
				break
			fi
		done
        echo "User selected Ok and the node name as:" $NODENAME
    else
        echo "User selected Cancel."
    fi

    echo "(Exit status was $exitstatus)"

    #No of cores:
    cpu_cores=$(nproc)
    exitstatus=$?
    if [ $exitstatus = 0 ]; then
        local cores
        while true ; do
            cores=$(whiptail --inputbox "Enter the amount of CPU Cores to use.\nYour CPU has $cpu_cores cores." 8 45 10 --title "Node Setup" 3>&1 1>&2 2>&3)
            expr $cores + 0 &> /dev/null
            if [ $? -eq 0 ] && [ $cores -ge 1 ] && [ $cores -le 32 ]; then
                sed -i "6c CORES=$cores" $installdir/.env
                break
            else
                printf "Please enter an integer greater than 1 and less than 32, and your input is incorrect, please re-enter!\n"
                whiptail --title "ERROR" --msgbox "The number of cores cannot contain spaces. Also enter an integer greater than 1 and less than 32, please re-enter!\nTry again." 8 78
            fi
        done
        echo "User selected Ok and the amount of cores as:" $cores
    else
        echo "User selected Cancel."
    fi

    echo "(Exit status was $exitstatus)"


    #mnemic seed prompt
    local mnemonic=""
	local gas_adress=""
	local balance=""
    exitstatus=$?
    if [ $exitstatus = 0 ]; then
        while true ; do
            mnemonic=$(whiptail --inputbox "Enter your gas account mnemonic seed." 8 39 --title "Node Setup" 3>&1 1>&2 2>&3)
            #read -p "Enter your gas account mnemonic: " mnemonic
            if [ -z "$mnemonic" ] || [ "$(node $installdir/scripts/console.js utils verify "$mnemonic")" == "Cannot decode the input" ]; then
                whiptail --title "ERROR" --msgbox "Enter a legal mnemonic, and it cannot be empty!\nTry again." 8 78
                printf "Please enter a legal mnemonic, and it cannot be empty!\n"
            else
                echo "----------Verifying your mnemonic seed now. Please wait! If an ERROR occurs you will be prompted to re-enter your seed----------"
                gas_adress=$(node $installdir/scripts/console.js utils verify "$mnemonic")
                balance=$(node $installdir/scripts/console.js --substrate-ws-endpoint "wss://khala.api.onfinality.io/public-ws" chain free-balance $gas_adress 2>&1)
                balance=$(echo $balance | awk -F " " '{print $NF}')
                balance=$(echo "$balance / 1000000000000"|bc)
                if [ `echo "$balance > 0.1"|bc` -eq 1 ]; then
                    sed -i "8c MNEMONIC=$mnemonic" $installdir/.env
                    sed -i "9c GAS_ACCOUNT_ADDRESS=$gas_adress" $installdir/.env
                    echo "----------Successfully verified mnemonic seed!----------"
                    sleep 2
                    break
                else
                    printf "Account PHA is less than 0.1!\n"
                fi
            fi
        done
    else
        echo "User selected Cancel."
        exit   1
    fi

    #add pool address
    
    local pool_addr=""
    exitstatus=$?
    if [ $exitstatus = 0 ]; then
        while true ; do
            #read -p "Enter your pool address: " pool_addr
            pool_addr=$(whiptail --inputbox "Enter your pool address:" 8 39 --title "Node Setup" 3>&1 1>&2 2>&3)
            if [ -z "$pool_addr" ] || [ "$(node $installdir/scripts/console.js utils verify "$pool_addr")" == "Cannot decode the input" ]; then
                whiptail --title "ERROR" --msgbox "Please enter a legal pool address, and it cannot be empty!\nTry again." 8 78
                printf "Please enter a legal pool address, and it cannot be empty!\n"
            else
                sed -i "10c OPERATOR=$pool_addr" $installdir/.env
                echo "----------Successfully verified pool address!----------"
                sleep 2
                break
            fi
        done
    else
        echo "User selected Cancel."
        exit   1
    fi
}

function start_node()
{
    if (whiptail --title "Phala Miner Installation" --yesno "Do you wish to start your node now?" 8 78); then
        echo "----------Your node is strating now hang tight...----------"
        sudo phala start
        echo "----------Almost done. Loading your Miner's status...----------"
        sudo phala status

    else
        echo "You decided not to strat the node now, exit status was $?."
        exit 1
fi
}

info_entry_question
download_script
enable_SGX
install_SGX_drivers
getting_miner_ready
#extracting_snapshot
snapshot_download
node_config
start_node
