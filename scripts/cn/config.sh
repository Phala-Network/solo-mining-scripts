#!/bin/bash

config_help()
{
cat << EOF
Usage:
	help			帮助信息
	show			查看配置信息
	set			重新设置
EOF
}

config_show()
{
	cat $basedir/config.json | jq .
}

config_set_all()
{
	local node_name=""
	read -p "输入节点名称: " node_name
	node_name=`echo "$node_name"`
	while [[ x"$node_name" =~ \ |\' ]]; do
		read -p "节点名称不能包含空格，请重新输入：" node_name
	done
	sed -i "2c \\  \"nodename\" : \"$node_name\"," $basedir/config.json &>/dev/null
	log_success "设置节点名称为: '$node_name' 成功"
	local ipaddr=""
	read -p "输入你的IP地址: " ipaddr
	ipaddr=`echo "$ipaddr"`
	if [ x"$ipaddr" == x"" ] || [ `echo $ipaddr | awk -F . '{print NF}'` -ne 4 ]; then
		log_err "IP地址格式错误，或者为空"
		exit 1
	fi
	sed -i "3c \\  \"ipaddr\" : \"$ipaddr\"," $basedir/config.json &>/dev/null
	log_success "设置IP地址为: '$ipaddr' 成功"

	local mnemonic=""
	read -p "输入你的Controllor账号助记词 : " mnemonic
	mnemonic=`echo "$mnemonic"`
	if [ x"$mnemonic" == x"" ]; then
		log_err "助记词不能为空"
		exit 1
	fi
	sed -i "4c \\  \"mnemonic\" : \"$mnemonic\"" $basedir/config.json &>/dev/null
	log_success "设置助记词为: '$mnemonic' 成功"
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
