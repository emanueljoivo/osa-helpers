#!/bin/bash

interface_name=$1
vlan_id=$2
net_addr=$3
net_mask=$4
vlan=${interface_name}.${vlan_id}

# Kernel modules to enable VLAN and bond interfaces
echo 'bonding' >> /etc/modules
echo '8021q' >> /etc/modules

echo ${vlan}
ip link add link ${interface_name} name ${vlan} type vlan id ${vlan_id}
ip -d link show ${vlan}

echo 'Attaching network address'
ip addr add ${net_addr}/24 brd ${net_mask} dev ${vlan}

ip link set dev ${vlan} up