#!/bin/bash

function config_show()
{
	cat $installdir/.env
}

function config_set_all()
{
	local cores
	while true ; do
		read -p "You use several cores to participate in mining: " cores
		expr $cores + 0 &> /dev/null
		if [ $? -eq 0 ] && [ $cores -ge 1 ] && [ $cores -le 32 ]; then
			sed -i "6c CORES=$cores" $installdir/.env
			break
		else
			printf "Please enter an integer greater than 1 and less than 32, and your enter is incorrect, please re-enter!\n"
		fi
	done

	local node_name
	while true ; do
		read -p "Enter your node name(not contain spaces): " node_name
		if [[ $node_name =~ \ |\' ]]; then
			printf "The node name cannot contain spaces, please re-enter!\n"
		else
			sed -i "7c NODE_NAME=$node_name" $installdir/.env
			break
		fi
	done

	local mnemonic=""
	local gas_adress=""
	local balance=""
	while true ; do
		read -p "Enter your gas account mnemonic: " mnemonic
		if [ -z "$mnemonic" ] || [ "$(node $installdir/scripts/console.js utils verify "$mnemonic")" == "Cannot decode the input" ]; then
			printf "Please enter a legal mnemonic, and it cannot be empty!\n"
		else
			gas_adress=$(node $installdir/scripts/console.js utils verify "$mnemonic")
			balance=$(node $installdir/scripts/console.js --substrate-ws-endpoint "wss://khala.api.onfinality.io/public-ws" chain free-balance $gas_adress 2>&1)
			balance=$(echo $balance | awk -F " " '{print $NF}')
			balance=$(echo "$balance / 1000000000000"|bc)
			if [ `echo "$balance > 0.1"|bc` -eq 1 ]; then
				sed -i "8c MNEMONIC=$mnemonic" $installdir/.env
				sed -i "9c GAS_ACCOUNT_ADDRESS=$gas_adress" $installdir/.env
				break
			else
				printf "Account PHA is less than 0.1!\n"
			fi
		fi
	done

	local pool_addr=""
	while true ; do
		read -p "Enter your pool address: " pool_addr
		if [ -z "$pool_addr" ] || [ "$(node $installdir/scripts/console.js utils verify "$pool_addr")" == "Cannot decode the input" ]; then
			printf "Please enter a legal pool address, and it cannot be empty!\n"
		else
			sed -i "10c OPERATOR=$pool_addr" $installdir/.env
			break
		fi
	done
}

function version_gt() { test "$(echo "$@" | tr " " "\n" | sort -V | head -n 1)" != "$1"; }

function config()
{
	if version_gt $(uname -r|awk -F "-" '{print $1}') "5.14"; then
		log_info "----------Your kernel version is greater than 5.13, the kernel version is too high. Please lower the kernel version!----------"
		exit 1
	fi
	log_info "----------Test confidenceLevel, waiting for Intel to issue IAS remote certification report!----------"
	local Level=$(phala sgx-test | awk '/confidenceLevel =/{ print $3 }' | tr -cd "[0-9]")
	if [ -z $Level ]; then
		log_info "----------Intel IAS certification has not passed, please check your motherboard or network!----------"
		exit 1
	elif [ $(echo "1 <= $Level"|bc) -eq 1 ] && [ $(echo "$Level <= 5"|bc) -eq 1 ]; then
		log_info "----------Your confidenceLevel is：$Level----------"
		case "$1" in
			show)
				config_show
				;;
			set)
				config_set_all
				;;
			*)
				phala_help
				break
		esac
	fi
}
