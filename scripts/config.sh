#!/bin/bash

config_help()
{
cat << EOF
Usage:
    help                                  show help information
    show                                  show configurations
    set                                   set configurations
EOF
}

config_show()
{
    cat $basedir/config.json | jq .
}

config_set_all()
{
	local node_name=""
	read -p "Enter phala node name (default:phala-node): " node_name
	node_name=`echo "$node_name"`
	if [ x"$node_name" == x"" ]; then
		node_name="phala-node"
	fi
	sed -i "2c \\  \"nodename\" : \"$node_name\"," $basedir/config.json &>/dev/null
	log_success "Set phala node name: '$node_name' successfully"

	local ipaddr=""
	read -p "Enter your local IP address : " ipaddr
	ipaddr=`echo "$ipaddr"`
	if [ x"$ipaddr" == x"" ]; then
		log_err "Set IP address faild"
	fi
	sed -i "3c \\  \"ipaddr\" : \"$ipaddr\"," $basedir/config.json &>/dev/null
	log_success "Set IP address: '$ipaddr' successfully"

    local mnemonic=""
	read -p "Enter your controllor mnemonic : " mnemonic
	mnemonic=`echo "$mnemonic"`
	if [ x"$mnemonic" == x"" ]; then
		log_err "Mnemonic can not be empty"
	fi
	sed -i "4c \\  \"mnemonic\" : \"$mnemonic\"" $basedir/config.json &>/dev/null
	log_success "Set your controllor mnemonic: '$mnemonic' successfully"
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