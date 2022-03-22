#!/usr/bin/env bash

function phala_scripts_update_container() {
  phala_scripts_check_envf
  phala_scripts_config_dockeryml
  local _container_name=$(awk -F':' '/container_name/ {print $NF}' ${phala_scripts_docker_ymlf} 2>/dev/null|grep "\-${1}$")
  if [ -z "$1" ];then
    phala_scripts_log info "Update phala images" cut
    phala_scripts_utils_docker pull
  elif [ ! -z "${_container_name}" ];then
    phala_scripts_log info "Update phala images" cut
    phala_scripts_utils_docker pull ${_container_name}
  else
    phala_scripts_help
    return 0
  fi
#   phala_scripts_stop_container $*
  phala_scripts_start $*
  phala_scripts_log info "Update success" cut
}

function phala_scripts_update_script() {
  type dig >/dev/null 2>&1 || apt install -y dnsutils
  local _update_txt_domain=""
  local _get_new_vesion="$(dig txt ${_update_txt_domain} +short | sed 's#"##g')"
  if [ "${_get_new_vesion}" == "${phala_scripts_version}" ] && [ "$1" != "now" ];then
    _phala_scripts_utils_printf_value=${phala_scripts_version}
    phala_scripts_log info "version [ %s ] is up to date" cut
    return 0
  fi
  phala_scripts_log info "Update phala script" cut
  local _get_nowtime="$(date +%s)"
  local _download_file_path="${phala_scripts_tmp_dir}/update_phala_${_get_nowtime}.zip"
  local _update_tmp_dir="${phala_scripts_tmp_dir}/phala_update_${_get_nowtime}"

  trap "rm -rf ${_download_file_path} ${_update_tmp_dir}" EXIT

  curl -fsSL ${phala_scripts_update_url} -o ${_download_file_path} && {
    unzip -oq ${_download_file_path} -d ${_update_tmp_dir}
  } || {
    phala_scripts_log error "Update Fail" cut
  }
  local _get_update_dir=$(find ${_update_tmp_dir} -maxdepth 1 -type d |sed 1d)
  chattr -i -R ${phala_scripts_temp_dir}
  cp -arf ${_get_update_dir}/* ${phala_scripts_dir}
  chattr +i -R ${phala_scripts_temp_dir}
  phala_scripts_log info "Update success" cut

  # rm -rf ${phala_scripts_tmp_dir}/update_phala-main.zip ${_update_tmp_dir}
  
}

function phala_scripts_update() {
  case $1 in
    script)
      phala_scripts_update_script $*
    ;;
    clean)
      phala_scripts_stop_container
      phala_scripts_log info "Clean data" cut
      rm -rf ${khala_data_path_default} ${khala_data_path_default}_dev
      phala_scripts_update_container
    ;;
    *)
      phala_scripts_update_container $*
    ;;
  esac
}