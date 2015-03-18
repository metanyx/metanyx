#!/usr/bin/env bash

# git pull

# check for issues with pull

# check against version in .info
#  if not changed, exit

dirname = $0

. /opt/ansible/hacking/env-setup

cd $dirname
git pull
ansible-playbook playbook.yml -i metanyx --connection=local
