#!/bin/sh

if [ "$#" -ne 4 ]; then
  echo "usage: $0 <interface> <vlan_id> <net_address> <net_mask>"
  exit 1
fi

INTERFACE=$1
VLAN_ID=$2
VLAN_NAME=${INTERFACE}.${VLAN_ID}
NET_ADDR=$3
NET_MASK=$4

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

exit 0