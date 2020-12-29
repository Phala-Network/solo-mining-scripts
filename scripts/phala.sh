#!/bin/bash

basedir=/opt/phala
scriptdir=$basedir/scripts

source $scriptdir/utils.sh
source $scriptdir/config.sh
source $scriptdir/install_phala.sh
source $scriptdir/start.sh
source $scriptdir/stop.sh
source $scriptdir/update.sh
source $scriptdir/logs.sh
source $scriptdir/status.sh

help()
{
cat << EOF
Usage:
    help                            show help information
    install {init|isgx|dcap}        install your phala node
    start {node|pruntime|phost}     start your node module
    stop {node|pruntime|phost}		use docker kill to stop module
	config							configure your phala node
    status							show module configurations
    update {clean}					update phala node
    logs {node|pruntime|phost}		show node module logs
EOF
exit 0
}

###########################################Switch#########################################

case "$1" in
	install)
		install $2
		;;
	config)
		config $2
		;;
	start)
		start $2
		;;
	stop)
		stop $2
		;;
	status)
		status $@
		;;
	update)
		update $2
		;;
	logs)
		logs $2
		;;
	uninstall)
		$installdir/scripts/uninstall.sh
		;;
	help)
		help
		;;
	*)
		help
esac

exit 0