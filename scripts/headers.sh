#!/usr/bin/env bash

function phala_scripts_headers_get() {
  phala_scripts_log info "Download header filelist" cut
  local _headers_get_path=${HEADERS_VOLUMES%:*}
  set +e
  local _headers_get_uri=($(curl --connect-timeout 10 -sSLf ${phala_scripts_headers_geturl}));res_status=$?
  set -e
  if [ ${res_status} -ne 0 ];then
    _phala_scripts_utils_printf_value=${phala_scripts_headers_geturl}
    phala_scripts_log error "%s \nDownload header filelist failed, check your network connecting." cut
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
        phala_scripts_log info "find %s, checked."
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
      phala_scripts_log error "%s Download header files failed, check your network connecting."
    fi
    if [ "${fmd5}" != "$(md5sum ${_headers_get_path}/${fname}|awk '{print $1}')" ];then
      _phala_scripts_utils_printf_value="${phala_scripts_headers_gethost}/${findex}\n${_headers_get_path}/${fname}\n${fmd5}"
      phala_scripts_log error "%s Check header files failed, run manually."
    else
      _phala_scripts_utils_printf_value=${_headers_get_path}/${fname}
      phala_scripts_log info "%s Download success, Checked."
    fi
  done
}

function phala_scripts_headers_import() {
  phala_scripts_log warn "Must stop headers-cache & pherry befor import headers." cut
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
      phala_scripts_log error "%s Import failed, try again."
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