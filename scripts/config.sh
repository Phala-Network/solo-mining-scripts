#!/usr/bin/env bash
phala_scripts_version=v0.2.0
# phala_scripts_update_url="https://github.com/Phala-Network/solo-mining-scripts/archive/main.zip"
phala_scripts_update_url="https://github.com/Phala-Network/solo-mining-scripts/archive/v2.zip"

phala_scripts_support_system=(
  "Ubuntu 18.04"
  "Ubuntu 20.04"
  "Ubuntu 21.04"
  "Ubuntu 21.10"
)
phala_scripts_support_kernel=(
  "4.15"
  "5.4"
  "5.11"
  "5.13"
)

phala_scripts_support_language=(
  "US" "English"
  "CN" "中文"
)

phala_scripts_dependencies_default_soft=(
  jq curl wget unzip zip gettext
)

# docker-compose: docker + docker-compose
phala_scripts_dependencies_other_soft=(
  docker docker-compose node
)

phala_pro_msg="MAINNET"
phala_dev_msg="TESTNET"

phala_scripts_utils_apt_source_cn="https://mirrors.163.com"
phala_scripts_install_docker_compose_cn="https://get.daocloud.io/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)"
phala_scripts_install_docker_compose="https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)"
phala_scripts_install_intel_sgx_deb="https://download.01.org/intel-sgx/sgx_repo/ubuntu/intel-sgx-deb.key"
phala_scripts_install_intel_addapt_deb="deb https://download.01.org/intel-sgx/sgx_repo/ubuntu focal main"
phala_scripts_install_intel_old_device="https://download.01.org/intel-sgx/latest/linux-latest/distro/ubuntu20.04-server/sgx_linux_x64_driver_1.41.bin"
phala_scripts_install_setupnode="https://deb.nodesource.com/setup_lts.x"

export phala_scripts_version \
       phala_scripts_support_system \
       phala_scripts_support_kernel \
       phala_scripts_dependencies_default_soft \
       phala_scripts_dependencies_other_soft \
       phala_pro_msg \
       phala_dev_msg \
       phala_scripts_utils_apt_source_cn \
       phala_scripts_install_docker_compose_cn \
       phala_scripts_install_docker_compose \
       phala_scripts_install_intel_sgx_deb \
       phala_scripts_install_intel_addapt_deb \
       phala_scripts_install_intel_old_device \
       phala_scripts_install_setupnode

phala_scripts_config_default() {

  phala_scripts_sgxtest_image=phalanetwork/phala-sgx_detect
  phala_node_image=phalanetwork/khala-node
  phala_node_dev_image=phalanetwork/khala-pt3-node
  phala_pruntime_image=phalanetwork/phala-pruntime
  phala_pherry_image=phalanetwork/phala-pherry

  phala_scripts_public_ws="wss://khala.api.onfinality.io/public-ws"
  phala_scripts_public_ws_dev="wss://pc-test-3.phala.network/khala/ws"
  #phala_scripts_public_ws_dev="wss://127.0.0.1:9944/khala/ws"

  phala_scripts_kusama_ws="wss://kusama.api.onfinality.io/public-ws"
  phala_scripts_kusama_ws_dev="wss://pc-test-3.phala.network/rococo/ws"
  #phala_scripts_kusama_ws_dev="wss://127.0.0.1:9945/public-ws"

  khala_data_path_default="/var/khala"

  phala_scripts_tools_dir="${phala_scripts_dir}/tools"
  phala_scripts_conf_dir="${phala_scripts_dir}/conf"
  phala_scripts_temp_dir="${phala_scripts_dir}/temp"
  phala_scripts_tmp_dir="${phala_scripts_dir}/tmp"
  phala_scripts_log_dir="${phala_scripts_dir}/log"
  [ -d "${phala_scripts_conf_dir}" ] || mkdir ${phala_scripts_conf_dir}
  [ -d "${phala_scripts_tmp_dir}" ] || mkdir ${phala_scripts_tmp_dir}
  [ -d "${phala_scripts_log_dir}" ] || mkdir ${phala_scripts_log_dir}

  phala_scripts_temp_ymlf="${phala_scripts_temp_dir}/docker-compose.yml.template"
  phala_scripts_docker_ymlf="${phala_scripts_conf_dir}/phala-docker.yml"
  phala_scripts_temp_envf="${phala_scripts_temp_dir}/phala-env.template"
  phala_scripts_docker_envf="${phala_scripts_conf_dir}/phala-env"

  # source env
  [ -f "${phala_scripts_docker_envf}" ] && export $(sed '/MNEMONIC=/d' ${phala_scripts_docker_envf})

  # check user env and source data
  if [ ! -z "${NODE_VOLUMES}" ];then
    local _data_path=${NODE_VOLUMES%:*}
    # khala_data_path_default=${_data_path%/[dev pro]*}
    # khala_data_path_default=${_data_path%_[dev pro]*}
    [ "${PHALA_ENV}" == "${phala_dev_msg}" ] && khala_data_path_default=${_data_path%_dev/*} || khala_data_path_default=${_data_path%/*}
  fi
  
  export phala_scripts_sgxtest_image \
         phala_node_image \
         phala_node_dev_image \
         phala_pruntime_image \
         phala_pherry_image \
         phala_scripts_public_ws \
         phala_scripts_public_ws_dev \
         phala_scripts_kusama_ws \
         phala_scripts_kusama_ws_dev \
         khala_data_path_default \
         phala_scripts_tools_dir \
         phala_scripts_conf_dir \
         phala_scripts_temp_dir \
         phala_scripts_tmp_dir \
         phala_scripts_temp_ymlf \
         phala_scripts_docker_ymlf \
         phala_scripts_temp_envf \
         phala_scripts_docker_envf
}

function phala_scripts_config_dockeryml() {
  if [ ! -f ${phala_scripts_temp_ymlf} ];then
    _phala_scripts_utils_printf_value="${phala_scripts_temp_ymlf}"
    phala_scripts_log error "%s\nTemplate file not found!" cut
  fi
  # check and install
  phala_scripts_check_sgxdevice
  local _phala_docker_yml=""
  for d in "${phala_scripts_sgx_device_path[@]}";do
    _phala_docker_yml="${_phala_docker_yml}\n    - ${d}"
  done
  [ -f ${phala_scripts_docker_ymlf} ] && chattr -i ${phala_scripts_docker_ymlf}
  sed "s#phala_template_ymlvalue#${_phala_docker_yml}#g" ${phala_scripts_temp_ymlf} > ${phala_scripts_docker_ymlf}
  chattr +i ${phala_scripts_docker_ymlf}
  if [ -f "${phala_scripts_dir}/docker-compose.yml" ] && [ -L "${phala_scripts_dir}/docker-compose.yml" ];then
    unlink ${phala_scripts_dir}/docker-compose.yml
  elif [ -f "${phala_scripts_dir}/docker-compose.yml" ] && [ ! -L "${phala_scripts_dir}/docker-compose.yml" ];then
    _bak_time=$(date +%s)
    phala_scripts_log info "move ${phala_scripts_dir}/docker-compose.yml ${phala_scripts_dir}/docker-compose.yml.${_bak_time}.bak" cut
    mv ${phala_scripts_dir}/docker-compose.yml ${phala_scripts_dir}/docker-compose.yml.${_bak_time}.bak
  fi

  ln -s ${phala_scripts_docker_ymlf} ${phala_scripts_dir}/docker-compose.yml
}

function phala_scripts_config_show() {
    cat ${phala_scripts_docker_envf}
}

function phala_scripts_config_set_nodename() {
  # set nodename
  while true ; do
    local _node_name=$(phala_scripts_utils_read "Enter your node name(not contain spaces)")
    if [[ "${_node_name}" =~ \ |\' ]]; then
      phala_scripts_log warn "The node name cannot contain spaces, please re-enter!" cut
    else
      echo ${_node_name}
      break
    fi
  done
}

function phala_scripts_config_set_locale() {
  if [[ "$(tty)" =~ "pts" ]];then
    :
  else
    export PHALA_LANG=US
    echo US
    return 0
  fi
  # set locale
  if [ "${PHALA_LANG}" == "CN" ] || [ "${PHALA_LANG}" == "US" ];then
    _phala_scripts_utils_printf_value="${PHALA_LANG}"
  else
    _phala_scripts_utils_printf_value="US"
  fi
  # local _phala_lang=$(phala_scripts_utils_read "Set phala locale" ${_phala_scripts_utils_printf_value})
  local _set_lang=$(phala_scripts_utils_gettext "Set Language")
  local _set_choices=$(phala_scripts_utils_gettext "Choices")
  local _phala_lang=$(whiptail --title "${_set_lang}" --clear --default-item ${_phala_scripts_utils_printf_value} --menu "${_set_choices}" 12 35 5 ${phala_scripts_support_language[@]} 3>&1 1>&2 2>&3)
  local _phala_lang_tr=$(echo ${_phala_lang}|tr a-z A-Z)
  if [ "${_phala_lang_tr}" == "CN" ] || [ "${_phala_lang_tr}" == "US" ];then
    result_msg=${_phala_lang_tr}
  else
    result_msg=${_phala_scripts_utils_printf_value}
  fi
  export PHALA_LANG=${result_msg}
  echo ${result_msg}
}

function phala_scripts_config_set() {
  # Usage: show locale dev 

  local _phala_env=${phala_pro_msg}

  case $1 in
    '')
      :
    ;;
    show)
      phala_scripts_config_show
      return 0
    ;;
    locale)
      phala_scripts_check_envf
      phala_scripts_config_input_lang="$(phala_scripts_config_set_locale)"
      export PHALA_LANG=${phala_scripts_config_input_lang}
      phala_scripts_utils_setlocale
      chattr -i ${phala_scripts_docker_envf}
      sed -i "s#PHALA_LANG=.*#PHALA_LANG=${phala_scripts_config_input_lang}#g" ${phala_scripts_docker_envf}
      chattr +i ${phala_scripts_docker_envf}
      # print sucess
      phala_scripts_log info "Set success" cut
      return 0
    ;;
    dev|testnet)
      _phala_env=${phala_dev_msg}
      export phala_node_image=${phala_node_dev_image}
      export phala_scripts_public_ws=${phala_scripts_public_ws_dev}
      export phala_scripts_kusama_ws=${phala_scripts_kusama_ws_dev}
    ;;
    *)
      phala_scripts_help
      _phala_scripts_error_trap=false
      return 1
    ;;
  esac

  # set locale (first run)
  if [ -z "${PHALA_LANG}" ];then
    export phala_scripts_config_input_lang="$(phala_scripts_config_set_locale)"
    export PHALA_LANG=${phala_scripts_config_input_lang}
    phala_scripts_utils_setlocale
  else
    export phala_scripts_config_input_lang=${PHALA_LANG}
  fi

  # check base
  phala_scripts_check_dependencies

  # check sgxdevice
  phala_scripts_check_sgxdevice

  # print env
  phala_scripts_log info "\t\t\t\t\t[ ${_phala_env} ]"

  # check temp
  if [ ! -f ${phala_scripts_temp_envf} ];then
    _phala_scripts_utils_printf_value="${phala_scripts_temp_envf}"
    phala_scripts_log error "%s\nTemplate file not found!" cut
  fi
  # add no change temp
  chattr +i ${phala_scripts_temp_dir}

  # get cpu level
  phala_scripts_log info "Test confidenceLevel, waiting for Intel to issue IAS remote certification report!" cut
  local _confidenceLevel=$(phala_scripts_check_sgxtest | awk '/confidenceLevel =/{ print $3 }' | tr -cd "[0-9]")
  if [ -z ${_confidenceLevel} ];then
    phala_scripts_log error "Intel IAS certification has not passed, please check your motherboard or network!"
  # 1 => level <= 5
  elif [ "${_confidenceLevel}" -ge 1 ] && [ "${_confidenceLevel}" -le 5 ];then
    _phala_scripts_utils_printf_value=${_confidenceLevel}
    phala_scripts_log info "Your confidenceLevel is：%s" cut
  fi

  # skip input err quit
  set +e

  # set core
  # local _cpu_s=$(LANG=en_US.UTF-8 lscpu|awk -F':' '/^CPU\(s\):/{print $2}')
  # local _cpu_sockets=$(LANG=en_US.UTF-8 lscpu|awk -F':' '/^Socket\(s\):/{print $2}')
  local _cpu_s=$(awk -F':' '/physical id/ {print $NF+1}' /proc/cpuinfo|tail -n 1)
  local _cpu_sockets=$(awk -F ':' '/^siblings/ {print $NF+0;exit}' /proc/cpuinfo)
  local _my_cpu_core_number=$((${_cpu_s}*${_cpu_sockets}))
  while true ; do
    local _cores=$(phala_scripts_utils_read "You use several cores to participate in mining")
    expr ${_cores} + 0 > /dev/null 2>&1
    if [ $? -eq 0 ] && [ $_cores -ge 1 ] && [ $_cores -le ${_my_cpu_core_number} ]; then
      export phala_scripts_config_input_cores=${_cores}
      break
    else
      _phala_scripts_utils_printf_value=${_my_cpu_core_number}
      phala_scripts_log warn "Please enter an integer greater than 1 and less than %s, and your enter is incorrect, please re-enter!"  cut
    fi
  done

  # set nodename
  export phala_scripts_config_input_nodename=$(phala_scripts_config_set_nodename)

  if [ "${_phala_env}" == "${phala_dev_msg}" ];then
    phala_scripts_public_ws=${phala_scripts_public_ws_dev}
  fi

  # set mnemonic gas_account_address
  local _mnemonic=""
  local _gas_adress=""
  local _balance=""
  while true ; do
    _mnemonic=$(phala_scripts_utils_read "Enter your gas account mnemonic")
    if [ -z "${_mnemonic}" ] || [ "$(node ${phala_scripts_tools_dir}/console.js utils verify "$_mnemonic")" == "Cannot decode the input" ]; then
      phala_scripts_log warn "Please enter a legal mnemonic, and it cannot be empty!" cut
    else
      _gas_adress=$(node ${phala_scripts_tools_dir}/console.js utils verify "$_mnemonic")
      _balance=$(node  ${phala_scripts_tools_dir}/console.js --substrate-ws-endpoint "${phala_scripts_public_ws}" chain free-balance $_gas_adress 2>&1)
      _balance=$(echo $_balance | awk -F " " '{print $NF}')
      [ -z "${_balance}" ] && _balance=0
      _balance=$(echo "$_balance / 1000000000000"|bc)
      if [ `echo "$_balance > 0.1"|bc` -eq 1 ]; then
        export phala_scripts_config_input_mnemonic=${_mnemonic}
        export phala_scripts_config_gas_account_address=${_gas_adress}
        break
      else
        phala_scripts_log warn "Account PHA is less than 0.1!" cut
      fi
    fi
  done
  
  # set operator
  local _pool_addr=""
  while true ; do
    local _pool_addr=$(phala_scripts_utils_read "Enter your pool address")
    if [ -z "${_pool_addr}" ] || [ "$(node ${phala_scripts_tools_dir}/console.js utils verify "$_pool_addr")" == "Cannot decode the input" ]; then
      phala_scripts_log warn "Please enter a legal pool address, and it cannot be empty!"
    else
      export phala_scripts_config_input_operator=${_pool_addr}
      break
    fi
  done

  set -e

  # add old scripts check (testnet is skip)
  if [ -d /var/khala-dev-node ] && [ -d /var/khala-pruntime-data ] && [ ! -L /var/khala-dev-node ] && [ ! -L /var/khala-pruntime-data ] && [ "${_phala_env}" != "${phala_dev_msg}" ];then
    phala_scripts_log info "Old scripts found"
    phala_scripts_config_set_migrate="y"
    phala_scripts_config_set_migrate=$(phala_scripts_utils_read "migrate(y/n)?"  "${phala_scripts_config_set_migrate}"| tr A-Z a-z)
    while true;do
      if [ "${phala_scripts_config_set_migrate}" == "y" ] || [ "${phala_scripts_config_set_migrate}" == "n" ];then
        break
      else
        :
      fi
    done
  fi

  # set custom datadir
  khala_data_path_default=$(phala_scripts_utils_read "Enter your Khala DATA PATH"  "${khala_data_path_default}")
  
  # khala_data_path_default="${khala_data_path_default%/}/$(echo -en ${_phala_env}|tr A-Z a-z)"
  if [ "${_phala_env}" == "${phala_dev_msg}" ];then
    # khala_data_path_default="${khala_data_path_default%/}_$(echo -en ${_phala_env}|tr A-Z a-z)"
    khala_data_path_default="${khala_data_path_default%/}_dev"
  else
    khala_data_path_default="${khala_data_path_default%/}"
    # add old scripts migrate
    if [ "${phala_scripts_config_set_migrate}" == "y" ];then
      phala_scripts_log info "migrate [ /var/khala-dev-node ] to [ ${khala_data_path_default}/node-data ]"
      mv /var/khala-dev-node ${khala_data_path_default}/node-data
      phala_scripts_log info "migrate [ /var/khala-pruntime-data ] to [ ${khala_data_path_default}/pruntime-data ]"
      mv /var/khala-pruntime-data ${khala_data_path_default}/pruntime-data
    fi
  fi

  # save conf as env file
  [ -f ${phala_scripts_docker_envf} ] && chattr -i ${phala_scripts_docker_envf}
  sed -e "s#NODE_IMAGE=.*#NODE_IMAGE=${phala_node_image}#g" \
      -e "s#PRUNTIME_IMAGE=.*#PRUNTIME_IMAGE=${phala_pruntime_image}#g" \
      -e "s#PHERRY_IMAGE=.*#PHERRY_IMAGE=${phala_pherry_image}#g" \
      -e "s#CORES=.*#CORES=${phala_scripts_config_input_cores}#g" \
      -e "s#NODE_NAME=.*#NODE_NAME=${phala_scripts_config_input_nodename}#g" \
      -e "s#MNEMONIC=.*#MNEMONIC=${phala_scripts_config_input_mnemonic}#g" \
      -e "s#GAS_ACCOUNT_ADDRESS=.*#GAS_ACCOUNT_ADDRESS=${phala_scripts_config_gas_account_address}#g" \
      -e "s#OPERATOR=.*#OPERATOR=${phala_scripts_config_input_operator}#g" \
      -e "s#phala_template_data_value#${khala_data_path_default}#g" \
      -e "s#PHALA_ENV=.*#PHALA_ENV=${_phala_env}#g" \
      -e "s#PHALA_LANG=.*#PHALA_LANG=${phala_scripts_config_input_lang}#g" \
      ${phala_scripts_temp_envf} > ${phala_scripts_docker_envf}
  chattr +i ${phala_scripts_docker_envf}

  if [ -f "${phala_scripts_dir}/.env" ] && [ -L "${phala_scripts_dir}/.env" ];then
    unlink ${phala_scripts_dir}/.env
  elif [ -f "${phala_scripts_dir}/.env" ] && [ ! -L "${phala_scripts_dir}/.env" ];then
    _bak_time=$(date +%s)
    phala_scripts_log info "move ${phala_scripts_dir}/.env ${phala_scripts_dir}/.env.${_bak_time}.bak" cut
    mv ${phala_scripts_dir}/.env ${phala_scripts_dir}/.env.${_bak_time}.bak
  fi
  ln -s ${phala_scripts_docker_envf} ${phala_scripts_dir}/.env

  # run config docker-compose.yml update sgx device
  phala_scripts_config_dockeryml

  # start all service
  phala_scripts_stop_container
  phala_scripts_config_default
  phala_scripts_start
  
  # print sucess
  phala_scripts_log info "Set successed" cut

}

function phala_scripts_config() {
  phala_scripts_config_default
  
}
