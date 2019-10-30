#!/usr/bin/env bash
# Run this with root privileges
# Only tested in Ubuntu 16.04

set -o errexit
set -o pipefail
set -o xtrace

_install_packages() {
  apt-get update && apt-get dist-upgrade
  apt-get install aptitude build-essential git ntp \
    ntpdate openssh-server python-dev sudo
}

# Install required packages
_install_packages

# Setting ssh keys pair
ssh-keygen

# Install source
readonly OSA_VERSION=18.1.9
readonly OSA_PATH=/opt/openstack-ansible

git clone -b "${OSA_VERSION}" https://git.openstack.org/openstack/openstack-ansible "${OSA_PATH}"
cd "${OSA_PATH}"

scripts/bootstrap-ansible.sh

exit 0