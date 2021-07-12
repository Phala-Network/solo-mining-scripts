#!/bin/bash

uninstall()
{
	if [ -f /usr/bin/phala ]; then
		docker kill phala-phost
		docker kill phala-pruntime
		docker kill phala-node
		docker kill phala-pruntime-bench
		docker image prune -a
		rm -r $HOME/phala-node-data
		rm -r $HOME/phala-pruntime-data
		rm /usr/bin/phala
	fi

	rm -rf $installdir

	log_success "---------------删除 phala 挖矿套件成功---------------"
}
