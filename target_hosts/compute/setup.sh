#!/bin/sh
# Run this with root privileges

set -e

install_ubuntu_packages() {
  apt-get update && apt-get dist-upgrade

  apt-get install bridge-utils debootstrap ifenslave ifenslave-2.6 \
    iproute2 lsof lvm2 chrony openssh-server sudo tcpdump vlan python
}

set_ssh_pub_key() {
  PUB_KEY_FILE=key.pub

  if [ -f "${PUB_KEY_FILE}" ]; then
    cat ${PUB_KEY_FILE} >> /root/.ssh/authorized_keys
  else
    echo "${PUB_KEY_FILE} does not found, please add the pub key on this the directory level"
  fi
}

INTERFACE=eno1
VLAN_ID_1=405
VLAN_ID_2=406
VLAN_ID_3=407
VLAN_ID_4=408

create_vlans() {
  sh create_vlan.sh ${INTERFACE} ${VLAN_ID_1} 10.11.45.1 10.11.45.255
  sh create_vlan.sh ${INTERFACE} ${VLAN_ID_2} 10.11.46.1 10.11.46.255
  sh create_vlan.sh ${INTERFACE} ${VLAN_ID_3} 10.11.47.1 10.11.47.255
  sh create_vlan.sh ${INTERFACE} ${VLAN_ID_4} 10.11.48.1 10.11.48.255
}

remove_vlans() {
  ip link delete "${INTERFACE}.${VLAN_ID_1}"
  ip link delete "${INTERFACE}.${VLAN_ID_2}"
  ip link delete "${INTERFACE}.${VLAN_ID_3}"
  ip link delete "${INTERFACE}.${VLAN_ID_4}"
}

install_ubuntu_packages
set_ssh_pub_key
create_vlans
