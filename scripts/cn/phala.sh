#!/bin/bash

installdir=/opt/phala
scriptdir=$installdir/scripts

source $scriptdir/utils.sh
source $scriptdir/config.sh
source $scriptdir/install_phala.sh
source $scriptdir/logs.sh
source $scriptdir/start.sh
source $scriptdir/status.sh
source $scriptdir/stop.sh
source $scriptdir/uninstall.sh
source $scriptdir/update.sh

function phala_help()
{
cat << EOF
Usage:
	phala [OPTION]...

Options:
	help					展示帮助信息
	install					安装Phala挖矿套件
		<dcap>				安装DCAP驱动
		<isgx>				安装isgx驱动
	uninstall				卸载phala脚本
	start					启动挖矿(debug参数允许输出挖矿套件日志信息)
		<khala>				启动khala-node
	stop					停止挖矿程序
		<node>				停止phala-node容器
		<pruntime>			停止phala-pruntime容器
		<pherry>			停止phala-pherry容器
		<bench>				停止phala-pruntime-bench容器
	config					配置
		<show>				查看配置信息（直接看到配置文件所有信息）
		<set>				重新配置
	status					查看挖矿套件运行状态
	update					不清理容器数据，更新容器
		<clean>				清理容器数据，更新容器
		<script>			更新脚本
	logs					打印所有容器日志信息
		<node>				打印phala-node容器日志
		<pruntime>			打印phala-pruntime容器日志
		<pherry>			打印phala-pherry容器日志
		<bench>				打印phala-pruntime-bench容器日志
	sgx-test				运行挖矿测试程序
	score-test				获取机器评分
		<Parameter>			使用CPU核心数
EOF
exit 0
}

function sgx_test()
{
	if ! type jq curl wget unzip zip docker docker-compose node yq dkms > /dev/null; then install_depenencies;fi
	if [ ! -L /dev/sgx/enclave ]&&[ ! -L /dev/sgx/provision ]&&[ ! -c /dev/sgx_enclave ]&&[ ! -c /dev/sgx_provision ]&&[ ! -c /dev/isgx ]; then install_driver;fi

	if [ -L /dev/sgx/enclave ]&&[ -L /dev/sgx/provision ]&&[ -c /dev/sgx_enclave ]&&[ -c /dev/sgx_provision ]&&[ ! -c /dev/isgx ]; then
		docker run -ti --rm --name phala-sgx_detect --device /dev/sgx/enclave --device /dev/sgx/provision --device /dev/sgx_enclave --device /dev/sgx_provision swr.cn-east-3.myhuaweicloud.com/phala/phala-sgx_detect:latest
	elif [ ! -L /dev/sgx/enclave ]&&[ -L /dev/sgx/provision ]&&[ -c /dev/sgx_enclave ]&&[ -c /dev/sgx_provision ]&&[ ! -c /dev/isgx ]; then
		docker run -ti --rm --name phala-sgx_detect --device /dev/sgx/provision --device /dev/sgx_enclave --device /dev/sgx_provision swr.cn-east-3.myhuaweicloud.com/phala/phala-sgx_detect:latest
	elif [ ! -L /dev/sgx/enclave ]&&[ ! -L /dev/sgx/provision ]&&[ -c /dev/sgx_enclave ]&&[ -c /dev/sgx_provision ]&&[ ! -c /dev/isgx ]; then
		docker run -ti --rm --name phala-sgx_detect --device /dev/sgx_enclave --device /dev/sgx_provision swr.cn-east-3.myhuaweicloud.com/phala/phala-sgx_detect:latest
	elif [ ! -L /dev/sgx/enclave ]&&[ ! -L /dev/sgx/provision ]&&[ ! -c /dev/sgx_enclave ]&&[ -c /dev/sgx_provision ]&&[ ! -c /dev/isgx ]; then
		docker run -ti --rm --name phala-sgx_detect --device /dev/sgx_provision swr.cn-east-3.myhuaweicloud.com/phala/phala-sgx_detect:latest
	elif [ ! -L /dev/sgx/enclave ]&&[ ! -L /dev/sgx/provision ]&&[ ! -c /dev/sgx_enclave ]&&[ ! -c /dev/sgx_provision ]&&[ -c /dev/isgx ]; then
		docker run -ti --rm --name phala-sgx_detect --device /dev/isgx swr.cn-east-3.myhuaweicloud.com/phala/phala-sgx_detect:latest
	else
		log_info "----------未找到驱动文件，请检查驱动安装日志！----------"
		exit 1
	fi
}

function reportsystemlog()
{
	mkdir /tmp/systemlog
	ti=$(date +%s)
	dmidecode > /tmp/systemlog/system$ti.inf
	for container_name in phala-node phala-pruntime phala-pherry
	do
		if [ ! -z $(docker container ls -q -f "name=$container_name") ]; then
			case $container_name in
				phala-node)
					docker logs phala-node --tail 50000 > /tmp/systemlog/node$ti.inf
					;;
				phala-pruntime)
					docker logs phala-pruntime --tail 50000 > /tmp/systemlog/pruntime$ti.inf
					;;
				phala-pherry)
					docker logs phala-pherry --tail 50000 > /tmp/systemlog/pherry$ti.inf
					;;
				*)
					break
			esac
		fi
	done

	if ! type jq curl wget unzip zip docker docker-compose node yq dkms > /dev/null; then install_depenencies;fi
	if [ ! -L /dev/sgx/enclave ]&&[ ! -L /dev/sgx/provision ]&&[ ! -c /dev/sgx_enclave ]&&[ ! -c /dev/sgx_provision ]&&[ ! -c /dev/isgx ]; then install_driver;fi
	
	if [ -c /dev/sgx_vepc ]&&[ -c /dev/sgx ]; then
		docker run -ti --rm --name phala-sgx_detect --device /dev/sgx --device /dev/sgx_provision --device /dev/sgx_enclave --device /dev/sgx_vepc phalanetwork/phala-sgx_detect
	if [ -L /dev/sgx/enclave ]&&[ -L /dev/sgx/provision ]&&[ -c /dev/sgx_enclave ]&&[ -c /dev/sgx_provision ]&&[ ! -c /dev/isgx ]; then
		docker run -ti --rm --name phala-sgx_detect --device /dev/sgx/enclave --device /dev/sgx/provision --device /dev/sgx_enclave --device /dev/sgx_provision phalanetwork/phala-sgx_detect:latest
	elif [ ! -L /dev/sgx/enclave ]&&[ -L /dev/sgx/provision ]&&[ -c /dev/sgx_enclave ]&&[ -c /dev/sgx_provision ]&&[ ! -c /dev/isgx ]; then
		docker run -dti --rm --name phala-sgx_detect --device /dev/sgx/provision --device /dev/sgx_enclave --device /dev/sgx_provision swr.cn-east-3.myhuaweicloud.com/phala/phala-sgx_detect > /tmp/systemlog/testdocker-dcap.inf
	elif [ ! -L /dev/sgx/enclave ]&&[ ! -L /dev/sgx/provision ]&&[ -c /dev/sgx_enclave ]&&[ -c /dev/sgx_provision ]&&[ ! -c /dev/isgx ]; then
		docker run -dti --rm --name phala-sgx_detect --device /dev/sgx_enclave --device /dev/sgx_provision swr.cn-east-3.myhuaweicloud.com/phala/phala-sgx_detect > /tmp/systemlog/testdocker-dcap.inf
	elif [ ! -L /dev/sgx/enclave ]&&[ ! -L /dev/sgx/provision ]&&[ ! -c /dev/sgx_enclave ]&&[ -c /dev/sgx_provision ]&&[ ! -c /dev/isgx ]; then
		docker run -dti --rm --name phala-sgx_detect --device /dev/sgx_provision swr.cn-east-3.myhuaweicloud.com/phala/phala-sgx_detect > /tmp/systemlog/testdocker-dcap.inf
	elif [ ! -L /dev/sgx/enclave ]&&[ ! -L /dev/sgx/provision ]&&[ ! -c /dev/sgx_enclave ]&&[ ! -c /dev/sgx_provision ]&&[ -c /dev/isgx ]; then
		docker run -dti --rm --name phala-sgx_detect --device /dev/isgx swr.cn-east-3.myhuaweicloud.com/phala/phala-sgx_detect > /tmp/systemlog/testdocker-isgx.inf
	else
		log_info "----------未找到驱动文件，请检查驱动安装日志！----------"
		exit 1
	fi
	echo "$1 $score" > /tmp/systemlog/score$ti.inf
	zip -r /tmp/systemlog$ti.zip /tmp/systemlog/*
	fln="file=@/tmp/systemlog"$ti".zip"
	echo $fln
	sleep 10
	curl -F $fln http://118.24.253.211:10128/upload?token=1145141919
	rm /tmp/systemlog$ti.zip
	rm -r /tmp/systemlog
}

function score_test()
{
	if [ $# != 1 ]; then
		log_err "---------请填写要使用的机器核心的数量！----------"
		exit 1
	fi

	if ! type jq curl wget unzip zip docker docker-compose node yq dkms > /dev/null; then install_depenencies;fi
	if [ ! -L /dev/sgx/enclave ]&&[ ! -L /dev/sgx/provision ]&&[ ! -c /dev/sgx_enclave ]&&[ ! -c /dev/sgx_provision ]&&[ ! -c /dev/isgx ]; then install_driver;fi

	if [ ! -z $(docker container ls -q -f "name=phala-pruntime-bench") ]; then
		docker container rm --force phala-pruntime-bench
		docker image rm phalanetwork/phala-dev-pruntime-bench
		if [ -d /var/phala-pruntime-bench ]; then rm -rf /var/phala-pruntime-bench;fi
	fi

	if [ -L /dev/sgx/enclave ]&&[ -L /dev/sgx/provision ]&&[ -c /dev/sgx_enclave ]&&[ -c /dev/sgx_provision ]&&[ ! -c /dev/isgx ]; then
		docker run -dti --rm --name phala-pruntime-bench -p 8001:8000 -v /var/phala-pruntime-bench:/root/data -e EXTRA_OPTS="-c $1" --device /dev/sgx/enclave --device /dev/sgx/provision --device /dev/sgx_enclave --device /dev/sgx_provision phalanetwork/phala-dev-pruntime-bench
	elif [ ! -L /dev/sgx/enclave ]&&[ -L /dev/sgx/provision ]&&[ -c /dev/sgx_enclave ]&&[ -c /dev/sgx_provision ]&&[ ! -c /dev/isgx ]; then
		docker run -dti --rm --name phala-pruntime-bench -p 8001:8000 -v /var/phala-pruntime-bench:/root/data -e EXTRA_OPTS="-c $1" --device /dev/sgx/provision --device /dev/sgx_enclave --device /dev/sgx_provision phalanetwork/phala-dev-pruntime-bench
	elif [ ! -L /dev/sgx/enclave ]&&[ ! -L /dev/sgx/provision ]&&[ -c /dev/sgx_enclave ]&&[ -c /dev/sgx_provision ]&&[ ! -c /dev/isgx ]; then
		docker run -dti --rm --name phala-pruntime-bench -p 8001:8000 -v /var/phala-pruntime-bench:/root/data -e EXTRA_OPTS="-c $1" --device /dev/sgx_enclave --device /dev/sgx_provision phalanetwork/phala-dev-pruntime-bench
	elif [ ! -L /dev/sgx/enclave ]&&[ ! -L /dev/sgx/provision ]&&[ ! -c /dev/sgx_enclave ]&&[ -c /dev/sgx_provision ]&&[ ! -c /dev/isgx ]; then
		docker run -dti --rm --name phala-pruntime-bench -p 8001:8000 -v /var/phala-pruntime-bench:/root/data -e EXTRA_OPTS="-c $1" --device /dev/sgx_provision phalanetwork/phala-dev-pruntime-bench
	elif [ ! -L /dev/sgx/enclave ]&&[ ! -L /dev/sgx/provision ]&&[ ! -c /dev/sgx_enclave ]&&[ ! -c /dev/sgx_provision ]&&[ -c /dev/isgx ]; then
		docker run -dti --rm --name phala-pruntime-bench -p 8001:8000 -v /var/phala-pruntime-bench:/root/data -e EXTRA_OPTS="-c $1" --device /dev/isgx phalanetwork/phala-dev-pruntime-bench
	else
		log_info "----------未找到驱动文件，请检查驱动安装日志！----------"
		exit 1
	fi

	echo -e "\033[31m 受各种环境因素影响，性能评分有可能产生一定程度的波动！此评分为预览版本，预备主网上线有变化的可能！ \033[0m"
	echo "评分更新中，请稍等！"
	sleep 90
	score=$(curl -d '{"input": {}, "nonce": {}}' -H "Content-Type: application/json"  http://localhost:8001/get_info 2>/dev/null | jq -r .payload | jq .score)
	printf "您评分为: %d \n" $score
	if read -t 10 -p "您是否愿意上传您的评分到PhalaNetwork(默认10秒后自动上传)？ [Y/n] " input; then
		case $input in
			[yY][eE][sS]|[yY])
				reportsystemlog $1
				log_info "----------上传成功！----------"
				;;
			*)
				log_info "----------取消上传评分！----------"
				;;
		esac
	else
		reportsystemlog $1
	fi
}

if [ $(id -u) -ne 0 ]; then
	echo "请使用sudo运行!"
	exit 1
fi

case "$1" in
	install)
		install $2
		;;
	config)
		config $2
		;;
	start)
		check_version
		start
		;;
	presync)
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
		cd $installdir
		docker-compose up -d
		;;
	stop)
		stop $2
		;;
	status)
		status $2
		;;
	update)
		update $2
		;;
	logs)
		logs $2
		;;
	uninstall)
		uninstall
		;;
	sgx-test)
		sgx_test
		;;
	*)
		phala_help
		;;
esac

exit 0
