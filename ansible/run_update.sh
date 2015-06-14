#!/usr/bin/env bash

# TODO:
# check for issues with pull
# check against version in .info
#  if not changed, exit

dir=$(dirname $0)

. /opt/ansible/hacking/env-setup

cd $dir
git pull --rebase

ansible-playbook playbook.yml -i inventory --connection=local
