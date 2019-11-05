#!/usr/bin/env bash
# Run this with root privileges
# Only tested in Ubuntu 16.04

set -o errexit
set -o pipefail
# set -o xtrace

DIR_NAME="`dirname \"${0}\"`"              
DIR_PATH="`( cd \"${DIR_NAME}\" && pwd )`" 

if [ -z "${DIR_PATH}" ] ; then
  echo "For some reason, the path is not accessible to the script (e.g. permissions re-evaled after suid)"
  exit 1
fi

readonly INTERFACE_NAME=eno1

readonly VLANS=(
  ["405"]="10.11.45"
  ["406"]="10.11.46"
  ["407"]="10.11.47"
  ["408"]="10.11.48"
)

readonly BRIDGES=(
  br-mgmt
  br-storage
  br-vxlan
  br-vlan
)

_config_locales() {
  echo "Setting locales"
  locale-gen en_US en_US.UTF-8 pt_BR.UTF-8
  update-locale LANG=en_US.UTF-8
}

_install_dependencies() {
  echo "Upgrading/Installing dependencies"
  apt-get update && apt-get dist-upgrade -y 

  apt-get install -y bridge-utils debootstrap ifenslave ifenslave-2.6 \
    iproute2 lsof lvm2 chrony openssh-server sudo tcpdump vlan python

  service chrony restart  
}

_set_ssh_pub_key() {
  echo "Configuring ssh keys"
  local PUB_KEY_FILE="${DIR_PATH}/deployment-host-key.pub"

  if [[ -f "${PUB_KEY_FILE}" ]]; then
    cat ${PUB_KEY_FILE} >> /root/.ssh/authorized_keys
  else
    echo "${PUB_KEY_FILE} does not found, please add the pub key on this the directory level"
  fi
}

_create_bridges() {
  echo 'Setting up bridges'
  for BRIDGE in "${BRIDGES[@]}"; do         
    ip link add name ${BRIDGE} type bridge
  done  
}

_create_vlan() {
  local INTERFACE=$1
  local VLAN_ID=$2
  local VLAN_NAME="${INTERFACE}.${VLAN_ID}"
  local NET_ADDR=$3
  local BROADCAST_ADDR=$4

  echo "Creating ${VLAN_NAME}"
  ip link add link "${INTERFACE}" name "${VLAN_NAME}" type vlan id "${VLAN_ID}"
  ip -d link show "${VLAN_NAME}"

  echo "Attaching network address"
  ip addr add "${NET_ADDR}/24" brd "${BROADCAST_ADDR}" dev "${VLAN_NAME}"

  ip link set dev "${VLAN_NAME}" up
  echo "${VLAN_NAME} is up"
}

_create_vlans() {  

  for VLAN in "${!VLANS[@]}"; do     
    _create_vlan ${INTERFACE_NAME} ${VLAN} "${VLANS[$VLAN]}.1" "${VLANS[$VLAN]}.255"
  done  
}

_persist_configs() {
  local NETWORK_CONFIG_CUSTOM="${DIR_PATH}/vlans-interface"
  local NETWORK_CONFIG_PATH=/etc/network/interfaces
  # Kernel modules to enable VLAN protocols and interfaces bond
  echo 'bonding' >> /etc/modules
  echo '8021q' >> /etc/modules

  modprobe 8021q

  cat "${NETWORK_CONFIG_CUSTOM}" >> "${NETWORK_CONFIG_PATH}"
}

_remove_vlans() {  
  for VLAN in "${!VLANS[@]}"; do         
    ip link delete "${INTERFACE_NAME}.${VLAN}"
  done 
}

main() {
  USER_NAME=`whoami`

  if [[ ${USER_NAME} != root ]]; then 
    echo "This script must be executed as root"
  else 
    #_config_locales
    #_install_dependencies
    #_set_ssh_pub_key
    #_create_bridges
    #_create_vlans
    #_persist_configs
    #_remove_vlans    
    exit 0  
  fi  
}

main
