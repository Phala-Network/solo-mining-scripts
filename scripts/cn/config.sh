#!/bin/bash

help_config()
{
cat << EOF
Usage:
	help			帮助信息
	show			查看配置信息（直接看到配置文件所有信息）
	set			重新配置
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
		read -p "您使用几个核心参与挖矿: " cores
		expr $cores + 0 &> /dev/null
		if [ $? -eq 0 ] && [ $cores -ge 1 ] && [ $cores -le 32 ]; then
			sed -i "6c CORES=$cores" $installdir/.env
			break
		else
			printf "请输入大于1小于32的整数，该数据不正确，请重新输入！\n"
		fi
	done

	local node_name
	while true ; do
		read -p "请输入节点名称（不能包含空格）: " node_name
		if [[ $node_name =~ \ |\' ]]; then
			printf "节点名称不能包含空格，请重新输入!\n"
		else
			sed -i "7c NODE_NAME=$node_name" $installdir/.env
			break
		fi
	done

	local mnemonic=""
	local gas_adress=""
	local balance=""
	while true ; do
		read -p "输入你的GAS费账号助记词 : " mnemonic
		if [ -z "$mnemonic" ] || [ $(node $installdir/console.js verify "$mnemonic") == "Cannot decode the input" ]; then
			printf "请输入合法助记词,且不能为空！\n"
		else
			gas_adress=$(node $installdir/console.js verify "$mnemonic")
			balance=$(node $installdir/console.js --substrate-ws-endpoint "wss://pc-test.phala.network/khala/ws" free-balance $gas_adress 2>&1)
			balance=$(echo $balance | awk -F " " '{print $NF}')			
			balance=$(echo "${balance##*WorkerStat} / 1000000000000"|bc)
			if [ $(echo "$balance > 0.1"|bc) -eq 1 ]; then
				sed -i "8c MNEMONIC=$mnemonic" $installdir/.env
				sed -i "9c GAS_ACCOUNT_ADDRESS=$gas_adress" $installdir/.env
				break
			else
				printf "账户PHA小于0.1，请重新输入！\n"
			fi
		fi
	done

	local pool_addr=""
	while true ; do
		read -p "输入抵押池账户地址 : " pool_addr
		if [ -z "$pool_addr" ] || [ $(node $installdir/console.js verify "$pool_addr") == "Cannot decode the input" ]; then
			printf "请输入合法抵押池账户地址，且不能为空！\n"
		else
			sed -i "10c OPERATOR=$pool_addr" $installdir/.env
			break
		fi
	done
}

config()
{
	log_info "----------测试信用等级，正在等待Intel下发IAS远程认证报告！----------"
	local confidenceLevel=$(sgx_test | awk '/confidenceLevel =/{ print $3 }')
	if [ $(echo "$confidenceLevel >= 1"|bc) -eq 1 ] && [ $(echo "$confidenceLevel <= 5"|bc) -eq 1 ]; then
		log_info "----------Intel IAS认证没有通过，请检查您的主板或网络！----------"
		exit 1
	else
		log_info "----------您的信任等级是：$confidenceLevel----------"
		case "$1" in
			show)
				config_show
				;;
			set)
				config_set_all
				;;
			*)
				help_config
				break
		esac
	fi
}
