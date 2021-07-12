#!/bin/bash

echo_c()
{
	printf "\033[0;$1m$2\033[0m\n"
}

log_info()
{
	echo_c 33 "$1"
}

log_success()
{
	echo_c 32 "$1"
}

log_err()
{
	echo_c 35 "$1"
}

check_docker_status()
{
	local exist=`docker inspect --format '{{.State.Running}}' $1 2>/dev/null`
	if [ x"${exist}" == x"true" ]; then
		return 0
	elif [ "${exist}" == "false" ]; then
		return 2
	else
		return 1
	fi
}