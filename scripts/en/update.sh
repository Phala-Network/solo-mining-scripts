#!/bin/bash

update_script()
{
	log_info "----------Update phala script----------"

	mkdir -p /tmp/phala
	wget https://github.com/Phala-Network/solo-mining-scripts/archive/main.zip -O /tmp/phala/main.zip
	unzip /tmp/phala/main.zip -d /tmp/phala
	rm -rf /opt/phala/*
	cp -r /tmp/phala/solo-mining-scripts-main/scripts/en /opt/phala/scripts
	mv /opt/phala/scripts/phala.sh /usr/bin/phala
	chmod +x /usr/bin/phala
	chmod +x /opt/phala/scripts/*
	if [ $? -ne 0 ]; then
		log_err "----------Failed to update phala script----------"
	fi

	log_success "----------Update success----------"
	rm -rf /tmp/phala
}


update_clean()
{
	log_info "----------Clean phala node images----------"
	log_info "Kill phala-node phala-pruntime phala-phost"
	docker kill phalaphost
	docker kill phalapruntime
	docker kill phalanode
	docker image prune -a

	log_info "----------Clean data----------"
	rm -r $HOME/phalanodedata
	rm -r $HOME/phalapruntimedata

	local res=0
	log_info "----------Pull docker images----------"
	docker pull phalanetwork/phala-poc3-node
	res=$(($?|$res))
	docker pull phalanetwork/phala-poc3-pruntime
	res=$(($?|$res))
	docker pull phalanetwork/phala-poc3-phost
	res=$(($?|$res))

	if [ $res -ne 0 ]; then
		log_err "----------docker pull failed----------"
	fi

	log_success "----------Clean success----------"
}

update_noclean()
{
	log_info "----------Update phala node----------"
	log_info "Kill phala-node phala-pruntime phala-phost"
	docker kill phalaphost
	docker kill phalapruntime
	docker kill phalanode
	docker image prune -a

	local res=0
	docker pull phalanetwork/phala-poc3-node
	res=$(($?|$res))
	docker pull phalanetwork/phala-poc3-pruntime
	res=$(($?|$res))
	docker pull phalanetwork/phala-poc3-phost
	res=$(($?|$res))

	if [ $res -ne 0 ]; then
		log_err "----------docker pull failed----------"
	fi

	log_success "----------Update success----------"
}

update()
{
	case "$1" in
		clean)
			update_clean
			;;
		script)
			update_script
			;;
		"")
			update_noclean
			;;
		*)
			log_err "----------Parameter error----------"
	esac
}
