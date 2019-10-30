#!/usr/bin/env bash
# Run this with root privileges

set -o errexit
set -o pipefail
# set -o xtrace

_install_ubuntu_packages() {
  apt-get update && apt-get dist-upgrade

  apt-get install bridge-utils debootstrap ifenslave ifenslave-2.6 \
    iproute2 lsof lvm2 chrony openssh-server sudo tcpdump vlan python
}

_set_ssh_pub_key() {
  PUB_KEY_FILE=key.pub

  if [[ -f "${PUB_KEY_FILE}" ]]; then
    cat ${PUB_KEY_FILE} >> /root/.ssh/authorized_keys
  else
    echo "${PUB_KEY_FILE} does not found, please add the pub key on this the directory level"
  fi
}

_create_bridges() {
  echo 'Setting up bridges'

  ip link add name br-mgmt type bridge
  ip link add name br-storage type bridge
  ip link add name br-vxlan type bridge
  ip link add name br-vlan type bridge
}

_create_vlan() {
  local INTERFACE=$1
  local VLAN_ID=$2
  local VLAN_NAME=${INTERFACE}.${VLAN_ID}
  local NET_ADDR=$3
  local NET_MASK=$4

  # Kernel modules to enable VLAN protocols and interfaces bond
  echo 'bonding' >> /etc/modules
  echo '8021q' >> /etc/modules

  echo "Creating ${VLAN_NAME}"
  ip link add link "${INTERFACE}" name "${VLAN_NAME}" type vlan id "${VLAN_ID}"
  ip -d link show "${VLAN_NAME}"

  echo "Attaching network address"
  ip addr add "${NET_ADDR}"/24 brd "${NET_MASK}" dev "${VLAN_NAME}"

  ip link set dev "${VLAN_NAME}" up
  echo "${VLAN_NAME} is up"
}

readonly VLAN_ID_1=405
readonly VLAN_ID_2=406
readonly VLAN_ID_3=407
readonly VLAN_ID_4=408

_create_vlans() {
  local INTERFACE=eno1

  _create_vlan ${INTERFACE} ${VLAN_ID_1} 10.11.45.1 10.11.45.255
  _create_vlan ${INTERFACE} ${VLAN_ID_2} 10.11.46.1 10.11.46.255
  _create_vlan ${INTERFACE} ${VLAN_ID_3} 10.11.47.1 10.11.47.255
  _create_vlan ${INTERFACE} ${VLAN_ID_4} 10.11.48.1 10.11.48.255
}

_remove_vlans() {
  local INTERFACE=eno1
  local VLAN_ID_1=405
  local VLAN_ID_2=406
  local VLAN_ID_3=407
  local VLAN_ID_4=408
  ip link delete "${INTERFACE}.${VLAN_ID_1}"
  ip link delete "${INTERFACE}.${VLAN_ID_2}"
  ip link delete "${INTERFACE}.${VLAN_ID_3}"
  ip link delete "${INTERFACE}.${VLAN_ID_4}"
}

_install_ubuntu_packages
_set_ssh_pub_key
_create_vlans

exit 0
