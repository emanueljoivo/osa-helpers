#!/bin/bash
echo 'Setting up bridges'

ip link add name br-mgmt type bridge
ip link add name br-storage type bridge
ip link add name br-vxlan type bridge
ip link add name br-vlan type bridge