#!/bin/sh
# Run this with root privileges

set -e

# Packages required for ubuntu
apt-get update && apt-get dist-upgrade

apt-get install bridge-utils debootstrap ifenslave ifenslave-2.6 \
  iproute2 lsof lvm2 chrony openssh-server sudo tcpdump vlan python

# Configuring SSH keys
echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDIor2CPdFimyyV+sISJqIJCSX9P3o+kv0o70MfCua0n1BrvsGwFGlBJVc2E7ikIWEHqa6J/7BGBxIo2Ug04VWr8E6A9JPq3ZnAydegD7PCtU9nzH5+NW2F+Hzgt4n4/B5ooFGxw0dq6Tik6rUnEh6uf+VcWOlwCVmPsmTCB/AA5Ejjz8HpmgCHCHcFB3O0I/rgZXUx+07+OAB2vqc/NrCGlzvb0YxEzxCZzRzDeMFaBDFuaGu33niUqgW3S95/xyduoYzXXp7ZNYt0Q/9v2H0DvMLr14Z8rTXhfgmT+lBeUgqiouwa7QgC/XTs+m0n7+cjRJgbZ/zRuCsyAvOihhUD ig_adm@igctrspo" >> /root/.ssh/authorized_keys
