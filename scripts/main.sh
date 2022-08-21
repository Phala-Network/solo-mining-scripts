#!/usr/bin/env bash

# source 
. ${phala_scripts_dir}/scripts/utils.sh
. ${phala_scripts_dir}/scripts/log.sh
. ${phala_scripts_dir}/scripts/config.sh
. ${phala_scripts_dir}/scripts/check.sh
. ${phala_scripts_dir}/scripts/install.sh
. ${phala_scripts_dir}/scripts/status.sh
. ${phala_scripts_dir}/scripts/update.sh
. ${phala_scripts_dir}/scripts/headers.sh

function phala_scripts_help(){
phala_scripts_utils_gettext "Usage:\n"\
"	phala [OPTION]...\n"\
"\n"\
"Options:\n"\
"	help					display help information\n"\
"	install					install your phala node\n"\
"	uninstall				uninstall your phala scripts\n"\
"	start					start mining\n"\
"		<node | pruntime | pherry>\n"\
"	stop					stop mining\n"\
"		<node | pruntime | pherry>\n"\
"	config\n"\
"		<show>				display all configuration of your node\n"\
"		<testnet | locale>\n"\
"	status					display the running status of all components\n"\
"	update					update all containers without cleaning up the data\n"\
"		<clean>				update all containers, and clean up the data\n"\
"		<script>			update the script\n"\
"		<headers>			download headers\n"\
"	logs					print all container logs information\n"\
"		<node | pruntime | pherry>\n"\
"		<clean>				clean log\n"\
"	sgx-test				start the mining test program\n"\
"	version					display script version\n"
}

function phala_scripts_start() {
  phala_scripts_check_envf
  phala_scripts_config_dockeryml
  phala_scripts_utils_docker up -d
}

function phala_scripts_ps_container() {
  phala_scripts_check_envf
  phala_scripts_check_ymlf
  local _container_name=$(awk -F':' '/container_name/ {print $NF}' ${phala_scripts_docker_ymlf}|grep "\-${1}$")
  if [ -z "$1" ];then
    phala_scripts_utils_docker ps
  elif [ ! -z "${_container_name}" ];then
    phala_scripts_utils_docker ps ${_container_name}
  else
    phala_scripts_help
  fi
}

function phala_scripts_stop_container() {
  local _container_name=$(awk -F':' '/container_name/ {print $NF}' ${phala_scripts_docker_ymlf} 2>/dev/null|grep "\-${1}$")
  if [ -z "$1" ];then
    phala_scripts_utils_docker stop
    phala_scripts_utils_docker rm -f
  elif [ ! -z "${_container_name}" ];then
    phala_scripts_utils_docker stop ${_container_name}
    phala_scripts_utils_docker rm -f ${_container_name}
  else
    phala_scripts_help
  fi
}

function phala_scripts_remove_dockerimage() {
  local _container_name=$(awk -F':' '/container_name/ {print $NF}' ${phala_scripts_docker_ymlf} 2>/dev/null)
  for _dockerimage in ${_container_name};do
    docker image rm ${_dockerimage}
  done
}

function phala_scripts_logs_container() {
  set +e
  phala_scripts_check_envf
  phala_scripts_check_ymlf
  local _container_name=$(awk -F':' '/container_name/ {print $NF}' ${phala_scripts_docker_ymlf}|grep "\-${1}$")
  if [ -z "$1" ];then
    phala_scripts_utils_docker logs -f --tail 50
  elif [ ! -z "${_container_name}" ];then
    phala_scripts_utils_docker logs -f --tail 50 ${_container_name}
  else
    phala_scripts_help
  fi
}

function phala_scripts_uninstall() {
  phala_scripts_install_aptdependencies uninstall "${phala_scripts_dependencies_default_soft[@]}"
  phala_scripts_install_otherdependencies uninstall "${phala_scripts_dependencies_other_soft[@]}"
  phala_scripts_install_sgx uninstall
  [ -L "/usr/local/bin/phala" ] && unlink /usr/local/bin/phala
  chattr -i -R ${phala_scripts_conf_dir} ${phala_scripts_temp_dir} >/dev/null 2>&1
  phala_scripts_log info "Delete Phala Scripts: ${phala_scripts_dir}" cut
  rm -rf ${phala_scripts_dir}
  if [ "$1" == "clean" ];then
    phala_scripts_log info "Delete Phala Data: ${khala_data_path_default}" cut
    rm -rf ${khala_data_path_default} ${khala_data_path_default}_dev
    phala_scripts_log info "Uninstall phala node sucess" cut
  elif [ -z "$1" ];then
    phala_scripts_log info "Uninstall phala node sucess" cut
    phala_scripts_log info "\t\t\t\t\t Delete(rm -rf) \n \t\t\t\t\t Phala Data Dir: [ ${khala_data_path_default} ]" cut
  fi
}

function phala_scripts_clean_logs() {
  local _container_name=$(awk -F':' '/container_name/ {print $NF}' ${phala_scripts_docker_ymlf}|grep "\-${1}$")
  if [ -z "$1" ];then
    _container_name=$(awk -F':' '/container_name/ {print $NF}' ${phala_scripts_docker_ymlf})
  elif [ ! -z "${_container_name}" ];then
    :
  else
    phala_scripts_help
    return 1
  fi

  for _cname in ${_container_name[@]};do
    _phala_scripts_utils_printf_value="${_cname}"
    phala_scripts_log info "clean [ %s ] log." cut
    truncate -s 0 $(docker inspect --format='{{.LogPath}}' ${_cname});
  done
}

function phala_scripts_case() {
  local _check_link=$(readlink /usr/local/bin/phala)
  if [ ! -L "/usr/local/bin/phala" ];then
    ln -s ${phala_scripts_dir}/phala.sh /usr/local/bin/phala
  elif [ ! -f "/usr/local/bin/phala" ] && [ -L "/usr/local/bin/phala" ];then
    unlink /usr/local/bin/phala
    ln -s ${phala_scripts_dir}/phala.sh /usr/local/bin/phala
  elif [ -L "/usr/local/bin/phala" ] && [ "${_check_link%/*}" != "${phala_scripts_dir}" ];then
    unlink /usr/local/bin/phala
    ln -s ${phala_scripts_dir}/phala.sh /usr/local/bin/phala
  fi
  [ -x ${phala_scripts_dir}/phala.sh ] || chmod +x ${phala_scripts_dir}/phala.sh
  
  [ $(echo $1|grep -E "^start$|^presync$|^stop$|^status$|^logs$|^ps$|^sgx-test$"|wc -l) -eq 1 ] && phala_scripts_check_dependencies
  case "$1" in
    install|config)
      shift
      phala_scripts_config_set $*
    ;;
    version)
      printf "Phala Scripts Version: %s\n" ${phala_scripts_version}
    ;;
    start)
      phala_scripts_start
    ;;
    presync)
      if [ -f ${phala_scripts_docker_envf} ];then
        local phala_scripts_config_input_nodename=$(phala_scripts_config_set_nodename)
        sed -i "s#NODE_NAME=.*#NODE_NAME=${phala_scripts_config_input_nodename}#g" ${phala_scripts_docker_envf}
        phala_scripts_utils_docker up -d
      else
        phala_scripts_start
      fi
    ;;
    stop)
      shift
      phala_scripts_stop_container $*
    ;;
    status)
      set +e
      phala_scripts_status
    ;;
    update)
      shift
      phala_scripts_update $*
    ;;
    logs)
      export _phala_scripts_error_trap=false
      shift
      if [ "$1" == "clean" ];then
        shift
        phala_scripts_clean_logs $*
      else
        phala_scripts_logs_container $*
      fi
    ;;
    ps)
      shift
      phala_scripts_ps_container
    ;;
    uninstall)
      set +e
      phala_scripts_stop_container
      phala_scripts_remove_dockerimage
      shift
      phala_scripts_uninstall $*
    ;;
    sgx-test)
      phala_scripts_check_sgxtest
    ;;
    *)
      phala_scripts_help
    ;;
  esac
}

function phala_scripts_main() {
  # Error Quit
  set -e
  trap "phala_scripts_trap" EXIT INT
  export _phala_scripts_error_trap=true

  # Cannot run driectly
  if [ -z "${phala_scripts_dir}" ];then
  printf "\033[0;31m Cannot run driectly \033[0m\n"
    exit 1
  fi
  
  # run main case
  [ "$1" == "debug" ] && {
    # open shell debug
    set -x
    # shift OPTION
    shift
  }

  # default config [ first run ]
  phala_scripts_config

  # set locale lange
  phala_scripts_utils_setlocale

  # check 
  phala_scripts_check

  phala_scripts_case $*

}
