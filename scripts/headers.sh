#!/usr/bin/env bash

function phala_scripts_headers_get() {
  phala_scripts_log info "Download the header file index" cut
  local _headers_get_path=${HEADERS_VOLUMES%:*}
  set +e
  local _headers_get_uri=($(curl --connect-timeout 10 -sSLf ${phala_scripts_headers_geturl}));res_status=$?
  set -e
  if [ ${res_status} -ne 0 ];then
    _phala_scripts_utils_printf_value=${phala_scripts_headers_geturl}
    phala_scripts_log error "%s \nFailed to download the header index. Please check your network connection." cut
  fi
  for uri in ${_headers_get_uri[@]}
  do
    [ -z "$uri" ] && continue
    local fname=$(echo -en ${uri} |cut -d ',' -f1)
    local findex=$(echo -en ${uri} |cut -d ',' -f2)
    local fmd5=$(echo -en ${uri} |cut -d ',' -f3)
    if [ -f ${_headers_get_path}/${fname} ];then
      if [ "${fmd5}" == "$(md5sum ${_headers_get_path}/${fname}|awk '{print $1}')" ];then
        _phala_scripts_utils_printf_value=${_headers_get_path}/${fname}
        phala_scripts_log info "Found %s. Check passed."
        continue
      else
        rm -rf ${_headers_get_path}/${fname}
      fi
    fi
    set +e
    curl --connect-timeout 10 -o ${_headers_get_path}/${fname} -SLf ${phala_scripts_headers_gethost}/${findex};res_status=$?
    set -e
    if [ ${res_status} -ne 0 ];then
      _phala_scripts_utils_printf_value=${phala_scripts_headers_gethost}/${findex}
      phala_scripts_log error "%s Failed to download the header file. Please check your network connection."
    fi
    if [ "${fmd5}" != "$(md5sum ${_headers_get_path}/${fname}|awk '{print $1}')" ];then
      _phala_scripts_utils_printf_value="${phala_scripts_headers_gethost}/${findex}\n${_headers_get_path}/${fname}\n${fmd5}"
      phala_scripts_log error "%s Header file checksum failed. Please run manually."
    else
      _phala_scripts_utils_printf_value=${_headers_get_path}/${fname}
      phala_scripts_log info "%s Download succeeded. Check passed."
    fi
  done
}

function phala_scripts_headers_import() {
  phala_scripts_log warn "Need to stop headers-cache & pherry before importing headers" cut
  local _stop_yn=$(phala_scripts_utils_read "Continue? (y/n)")
  local _headers_get_path=${HEADERS_VOLUMES%:*}
  if [ "${_stop_yn}" == "y" ] || [ "${_stop_yn}" == "Y" ];then
    :
  else
    phala_scripts_log warn "Stoped."
    return 0
  fi
#   phala_scripts_utils_docker stop phala-headers-cache
#   phala_scripts_utils_docker stop phala-pherry
  phala_scripts_stop_container headers-cache
  phala_scripts_stop_container pherry
  for f in $(find ${_headers_get_path} -type f -name "genesis.bin" -or -name "kusama-headers.bin*")
  do
    fname="${f##*/}"
    _phala_scripts_utils_printf_value=${fname}
    phala_scripts_log info "Importing [ %s ]."
    set +e
    if [[ "${fname}" =~ "genesis" ]];then
    #   phala_scripts_utils_docker run --entrypoint "/root/headers-cache import genesis ${fname}" phala-headers-cache
      docker run -ti --rm --name phala-headers-cache -v ${HEADERS_VOLUMES} ${phala_headers_image} import genesis ${fname}; _run_status=$?
    elif [[ "${fname}" =~ "kusama-headers" ]];then
    #   phala_scripts_utils_docker run --entrypoint "/root/headers-cache import headers ${fname}" phala-headers-cache
      docker run -ti --rm --name phala-headers-cache -v ${HEADERS_VOLUMES} ${phala_headers_image} import headers ${fname}; _run_status=$?
    fi
    set -e
    if [ ${_run_status} -ne 0 ];then
      _phala_scripts_utils_printf_value=${fname}
      phala_scripts_log error "%s Import failed. Please try again."
    else
      _phala_scripts_utils_printf_value=${fname}
      phala_scripts_log info "%s Import successed."
    fi
  done
  phala_scripts_utils_docker up -d
}

function phala_scripts_headers() {
  if [ "${PHALA_MODEL}" != "PRUNE" ];then
    phala_scripts_log warn "Model is FULL, Stoped."
    return 0
  fi
  phala_scripts_headers_get
  phala_scripts_headers_import
}

function phala_scripts_headers_snapshot() {
  phala_scripts_log warn "Need to stop node before importing snapshot."
  local _stop_yn=$(phala_scripts_utils_read "Continue? (y/n)")
  if [ "${_stop_yn}" == "Y" ] || [ "${_stop_yn}" == "y" ];then
    :
  else
    phala_scripts_log info "Stoped."
    return 0
  fi
  phala_scripts_stop_container node
  unset _stop_yn

  local _kusama_data_path=${NODE_VOLUMES%:*}/polkadot/chains/ksmcc3
  phala_scripts_log warn "Will Delete All Your Kusama DATA!"
  phala_scripts_log warn "Delete ${_kusama_data_path}"
  local _stop_yn=$(phala_scripts_utils_read "Continue? (y/n)")
  if [ "${_stop_yn}" == "Y" ] || [ "${_stop_yn}" == "y" ];then
    if [ -d ${_kusama_data_path} ];then
      rm -rf ${_kusama_data_path}
      _phala_scripts_utils_printf_value=${_kusama_data_path}
      phala_scripts_log info "%s Delete succeeded."
    fi
  else
    phala_scripts_log info "Stoped."
    return 0
  fi
  phala_scripts_log info "Start downloading..."
  set +e
  [ -d ${_kusama_data_path} ] || mkdir -p ${_kusama_data_path}
  curl -o - -L ${phala_scripts_headers_snapshot_url} | lz4 -c -d - | tar -x -C ${_kusama_data_path};_run_status=$?
  if [ ${_run_status} -eq 0 ];then
    phala_scripts_log info "Download succeeded."
    phala_scripts_utils_docker up -d
  else
    phala_scripts_log error "Download failed. Please try again."
  fi
}