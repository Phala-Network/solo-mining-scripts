#!/bin/bash

config_help()
{
cat << EOF
Usage:
	help			show help information
	show			show configurations
	set			set configurations
EOF
}

config_show()
{
	cat $installdir/.env
}

config_set_all()
{
	local cores
	while true ; do
		read -p "You use several cores to participate in mining: " cores
		expr $cores + 0 &> /dev/null
		if [ $? -eq 0 ] && [ $cores -ge 1 ] && [ $cores -le 32 ]; then
			sed -i "4c CORES=$cores" $installdir/.env
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
			sed -i "5c NODE_NAME=$node_name" $installdir/.env
			break
		fi
	done

	local mnemonic=""
	local gas_adress=""
	local balance=""
	while true ; do
		read -p "Enter your gas account mnemonic: " mnemonic
		if [ -z "$mnemonic" ] || [ "$(node $installdir/console.js verify "$mnemonic")" == "Cannot decode the input" ]; then
			printf "Please enter a legal mnemonic, and it cannot be empty!\n"
		else
			gas_adress=$(node $installdir/console.js verify "$mnemonic")
			balance=$(node $installdir/console.js --substrate-ws-endpoint "wss://poc5-dev.phala.network/ws:9944" free-balance $gas_adress 2>&1)
			balance=$(expr ${balance:277} / 1000000000000)
			if [ `echo "$balance < 0.1"|bc` -eq 1 ]; then
				printf "Account PHA is less than 0.1!\n"
				exit 1
			fi
			sed -i "6c MNEMONIC=$mnemonic" $installdir/.env
			sed -i "7c GAS_ACCOUNT_ADDRESS=$gas_adress" $installdir/.env
			break
		fi
	done

	local pool_addr=""
	while true ; do
		read -p "Enter your pool address: " pool_addr
		if [ -z "$pool_addr" ] || [ "$(node $installdir/console.js verify $pool_addr)" == "Cannot decode the input" ]; then
			printf "Please enter a legal pool address, and it cannot be empty!\n"
		else
			sed -i "8c OPERATOR=$pool_addr" $installdir/.env
			break
		fi
	done
}

config()
{
	case "$1" in
		show)
			config_show
			;;
		set)
			config_set_all
			;;
		*)
			config_help
	esac
}
