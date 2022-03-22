#!/usr/bin/env bash

[ -z "${phala_scripts_dir}" ] && phala_scripts_dir=$(cd $(dirname $0);pwd)

# source inf
# . utils.sh

# loglevel=0

function phala_scripts_log() {
  # display level 
  # log type and level 
  # debug 0 | info 1 | warn 2 | error 3

  # default debug level
  [ -z "$loglevel" ] && loglevel=0

  local datetime=$(date +'%F %H:%M:%S')
  if [ -z "$1" ] && [ -z "$2" ] ;then
    phala_scripts_utils_red "[$datetime]\t" $(phala_scripts_utils_gettext 'log type or msg not found!!!')
    return 1
  fi
    
  local logtype=$(echo $1|tr a-z A-Z)
  local msg=$(phala_scripts_utils_gettext $2)
  [ ! -z $3 ] && local msg="\n\n\t${msg}\n"
  local source_path=$(caller 0 |sed "s#${phala_scripts_dir}#.#g"|awk '{print $3":"$1}')
  local logformat="[${datetime}\t${logtype}\t${source_path}]\t${msg}"
  [ ! -z $3 ] && local logformat="----------------------------------------------------------------------------------------------------\n${logformat}\n----------------------------------------------------------------------------------------------------" 


  case $logtype in
    DEBUG)
      [[ $loglevel -le 0 ]] && phala_scripts_utils_default ${logformat}
    ;;
    INFO)
      [[ $loglevel -le 1 ]] && phala_scripts_utils_green ${logformat}
    ;;
    WARN)
      [[ $loglevel -le 2 ]] && phala_scripts_utils_yellow ${logformat}
    ;;
    ERROR)
      [[ $loglevel -le 3 ]] && phala_scripts_utils_red ${logformat}
    ;;
  esac
  [ $logtype == "ERROR" ] && {
    export _phala_scripts_error_trap=false
    return 1 
  } || return 0

}
