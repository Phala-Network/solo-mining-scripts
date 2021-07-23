#!/bin/bash

update_script()
{
	log_info "----------Update phala script----------"

	mkdir -p /tmp/phala
	wget https://github.com/Phala-Network/solo-mining-scripts/archive/main.zip -O /tmp/phala/main.zip
	unzip /tmp/phala/main.zip -d /tmp/phala
	rm -rf /opt/phala/scripts
	cp -r /tmp/phala/solo-mining-scripts-main/scripts/en /opt/phala/scripts
	mv /opt/phala/scripts/phala.sh /usr/bin/phala
	chmod +x /usr/bin/phala
	chmod +x /opt/phala/scripts/*

	log_success "----------Update success----------"
	rm -rf /tmp/phala
}

update_clean()
{
	log_info "----------Clean phala node images----------"
	log_info "Kill phala-node phala-pruntime phala-pherry"
	cd $installdir
	docker-compose stop
	docker-compose rm $(docker-compose ps -aq)

	log_info "----------Clean data----------"
	rm -r /var/phala-node
	rm -r /var/phala-pruntime

	log_success "----------Clean success----------"

	phala start
}

update_noclean()
{
	log_info "----------Update phala node----------"
	log_info "Kill phala-node phala-pruntime phala-pherry"
	cd $installdir
	docker-compose stop
	docker-compose rm $(docker-compose ps -aq)

	phala start
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
