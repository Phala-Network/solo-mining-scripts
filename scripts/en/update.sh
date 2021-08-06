#!/bin/bash

check_version()
{
	wget https://github.com/Phala-Network/solo-mining-scripts/archive/poc5.zip -O /tmp/main.zip
	unzip -o /tmp/main.zip -d /tmp/phala
	if [ $(cat $installdir/.env | awk -F "=" '{print $NF}') != $(cat /tmp/phala/solo-mining-scripts-poc5/.env | awk -F "=" '{print $NF}') ]; then
		rm -rf /opt/phala/scripts
		rm /usr/bin/phala
		cp -r /tmp/phala/solo-mining-scripts-poc5/scripts/en /opt/phala/scripts
		chmod +x /opt/phala/scripts/*
		ln -s /opt/phala/scripts/phala.sh /usr/bin/phala
		exit 1
	fi
}

update_script()
{
	log_info "----------Update phala script----------"

	mkdir -p /tmp/phala
	wget https://github.com/Phala-Network/solo-mining-scripts/archive/poc5.zip -O /tmp/phala/main.zip
	unzip /tmp/phala/main.zip -d /tmp/phala
	rm -rf /opt/phala/scripts
	cp -r /tmp/phala/solo-mining-scripts-poc5/scripts/en /opt/phala/scripts
	chmod +x /opt/phala/scripts/*
	ln -s /opt/phala/scripts/phala.sh /usr/bin/phala

	log_success "----------Update success----------"
	rm -rf /tmp/phala
}

update_clean()
{
	log_info "----------Clean phala node images----------"
	log_info "Kill phala-node phala-pruntime phala-pherry"
	cd $installdir
	docker-compose stop
	docker container rm phala-node phala-pruntime phala-pherry
	docker image rm $(awk -F '[=]' 'NR==1,NR==3 {print $2}' $installdir/.env)

	log_info "----------Clean data----------"
	local node_data=$(awk -F '[=:]' 'NR==4 {print $2}' $installdir/.env)
	local pruntime_data=$(awk -F '[=:]' 'NR==5 {print $2}' $installdir/.env)
	if [ -d $node_data ]; then
		rm -rf $node_data
	elif [ -d $pruntime_data ]; then
		rm -rf $pruntime_data
	fi
	log_success "----------Clean success----------"

	start
}

update_noclean()
{
	log_info "----------Update phala node----------"
	log_info "Kill phala-node phala-pruntime phala-pherry"
	cd $installdir
	docker-compose stop
	docker container rm phala-node phala-pruntime phala-pherry
	docker image rm $(awk -F '[=]' 'NR==1,NR==3 {print $2}' $installdir/.env)

	start
	log_success "----------Update success----------"
}

update()
{
	case "$1" in
		clean)
			update_clean
			;;
		scripts)
			update_script
			;;
		"")
			update_noclean
			;;
		*)
			log_err "----------Parameter error----------"
	esac
}
