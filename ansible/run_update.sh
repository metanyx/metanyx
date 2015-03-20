#!/usr/bin/env bash

# git pull

# check for issues with pull

# check against version in .info
#  if not changed, exit

dir = $(dirname $0)

. /opt/ansible/hacking/env-setup

cd $dir
git pull
ansible-playbook playbook.yml -i metanyx --connection=local
