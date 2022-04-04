#!/usr/bin/env bash

phala_scripts_status_msg(){
phala_scripts_utils_gettext "Phala Status:\n"\
"----------------------------------------- Script version %s [ %s ] --------------------------------------\n"\
"	service name		service status			local node block height\n"\
"------------------------------------------------------------------------------------------------------------------\n"\
"	khala-node			%s				%s / %s\n"\
"	kusama-node			%s				%s / %s\n"\
"	phala-pruntime			%s\n"\
"	phala-pherry			%s				khala %s / kusama %s\n"\
"------------------------------------------------------------------------------------------------------------------\n"\
"	Status check							result\n"\
"------------------------------------------------------------------------------------------------------------------\n"\
"	khala chain synchronization status		%s, difference is %s\n"\
"	kusama chain synchronization status		%s, difference is %s\n"\
"	pherry synchronizes khala chain status		%s, difference is %s\n"\
"	pherry syncs kusama chain status  		%s, difference is %s\n"\
"------------------------------------------------------------------------------------------------------------------\n"\
"	account information		content\n"\
"------------------------------------------------------------------------------------------------------------------\n"\
"	node name           		%s\n"\
"	cores     			%s\n"\
"	GAS account address      	%s\n"\
"	GAS account balance      	%s\n"\
"	stake pool account address	%s\n"\
"	miner/worker public key 	%s\n"\
"	miner registration status	%s\n"\
"	miner score			%s\n"\
"------------------------------------------------------------------------------------------------------------------\n"\
"Please wait for the miner registration status to change to %s before proceeding on-chain operations\n"\
"If the chain synchronization is completed, but the pherry height is empty, please enter the group and ask\n"\
"----------------------------------- last refresh time [ %s ] ------------------------------------"
}

function phala_scripts_status_khala() {
  node ${phala_scripts_tools_dir}/console.js --substrate-ws-endpoint "${phala_scripts_public_ws}" chain $* 2>/dev/null
  # [ $1 == "free-balance" ] && echo 1000000000000000 || echo currentBlock: 10000000
}

function phala_scripts_status_kusama() {
  node ${phala_scripts_tools_dir}/console.js --substrate-ws-endpoint "${phala_scripts_kusama_ws}" chain sync-state 2>/dev/null
  # echo currentBlock: 10000000
}

function phala_scripts_status(){
  printf "$(phala_scripts_utils_gettext 'Getting public node block information, it may take some time...')\n"
  # echo "正在获取公共节点区块信息，可能需要一段时间..."
  trap "clear;exit" INT

  #minutes ago
  #find -type f -cmin -1
  [ "${PHALA_ENV}" == "${phala_dev_msg}" ] && {
    phala_scripts_public_ws=${phala_scripts_public_ws_dev}
    phala_scripts_kusama_ws=${phala_scripts_kusama_ws_dev}
  }

  local balance=$(phala_scripts_status_khala free-balance ${GAS_ACCOUNT_ADDRESS})
  local balance=$(echo "scale=4;${balance}/1000000000000"|bc)

  local khala_head_block=$(phala_scripts_status_khala sync-state |grep -oE "currentBlock: [0-9]{1,9}")
  local khala_head_block=${khala_head_block#*:}
  local khala_node_block=$(curl -sH "Content-Type: application/json" -d '{"id":1, "jsonrpc":"2.0", "method": "system_syncState", "params":[]}' http://0.0.0.0:9933 | jq '.result.currentBlock')

  local kusama_head_block=$(phala_scripts_status_kusama |grep -oE "currentBlock: [0-9]{1,9}")
  local kusama_head_block=${kusama_head_block#*:}
  local kusama_node_block=$(curl -sH "Content-Type: application/json" -d '{"id":1, "jsonrpc":"2.0", "method": "system_syncState", "params":[]}' http://0.0.0.0:9934 | jq '.result.currentBlock')

  local get_info=$(curl -sH "Content-Type: application/json" -d '{"input": {}, "nonce": {}}' http://0.0.0.0:8000/get_info -X POST)
  local publickey=$(echo $get_info | jq -r '.payload|fromjson.public_key')
  local registered=$(echo $get_info | jq -r '.payload|fromjson.registered')
  local blocknum=$(echo $get_info | jq -r '.payload|fromjson.blocknum')
  local headernum=$(echo $get_info | jq -r '.payload|fromjson.headernum')
  local score=$(echo $get_info | jq -r '.payload|fromjson.score')

  local _container_name=$(awk -F':' '/container_name/ {print $NF}' ${phala_scripts_docker_ymlf})
  for _container in ${_container_name[@]};do
    phala_scripts_utils_docker_status ${_container#*-}
    if [ $? -eq 0 ];then
      eval ${_container#*-}_status="running"
    elif [ $? -eq 2 ];then
      eval ${_container#*-}_status="exited"
    else
      eval ${_container#*-}_status="stop"
    fi
  done

  if [ $(echo "${balance} < 2"|bc) -eq 1 ]; then
    local balance_msg=$(phala_scripts_utils_gettext "Insufficient balance!")
    gas_balance="${balance} PHA $(phala_scripts_utils_red ${balance_msg})"
  else
    gas_balance="$(phala_scripts_utils_green ${balance}) PHA"
  fi

  if [ ${registered} = "true" ]; then
    registerStatus=$(phala_scripts_utils_gettext "Registered, you can use the miner’s public key to add a miner")
  else
    registerStatus=$(phala_scripts_utils_gettext "Not registered, please wait for the synchronization to complete")
    publickey=$(phala_scripts_utils_gettext "Waiting for the miner to register")
  fi

  SYNCED=$(phala_scripts_utils_green $(phala_scripts_utils_gettext "Synchronization completed"))
  SYNCING=$(phala_scripts_utils_yellow $(phala_scripts_utils_gettext "Synchronizing, please wait"))

  blockInfo=(${khala_node_block} ${khala_head_block} ${kusama_node_block} ${kusama_head_block} ${blocknum} ${headernum})
  compareOrder1=(1 3 0 2)
  compareOrder2=(0 2 4 5)

  for i in `seq 0 3`; do
    compare[${i}]=$(echo "${blockInfo[${compareOrder1[${i}]}]} - ${blockInfo[${compareOrder2[${i}]}]}")
    diff[${i}]=$(echo ${compare[${i}]} | bc)
    if [[ ${diff[${i}]} -lt 2 ]]; then
      sync_status[${i}]=${SYNCED}
    else
      sync_status[${i}]=${SYNCING}
    fi
  done

  clear
  printf "\r$(phala_scripts_status_msg)\n" \
        "${phala_scripts_version}" "${PHALA_ENV}"\
        "${node_status}" "${khala_node_block}" "${khala_head_block}" \
        "${node_status}" "${kusama_node_block}" "${kusama_head_block}" \
        "${pruntime_status}" \
        "${pherry_status}" "${blocknum}" "${headernum}" \
        "${sync_status[0]}" "${diff[0]}" \
        "${sync_status[1]}" "${diff[1]}" \
        "${sync_status[2]}" "${diff[2]}" \
        "${sync_status[3]}" "${diff[3]}" \
        "${NODE_NAME}" \
        "${CORES}" \
        "${GAS_ACCOUNT_ADDRESS}" \
        "${gas_balance}" \
        "${OPERATOR}" \
        "${publickey}" \
        "${registerStatus}" \
        "${score}" \
        "$(phala_scripts_utils_green $(phala_scripts_utils_gettext 'registered'))" \
        "$(date +'%F %H:%M:%S')"

  for seq_time in $(seq -w 60 -1 1);do
    printf "\r$(phala_scripts_utils_gettext ' -------------------------------------------  Remaining %s refresh  --------------------------------------------')" "${seq_time}s"
    sleep 1
  done
  printf "\n$(phala_scripts_utils_gettext Refreshing)...\n" 
  phala_scripts_status
}