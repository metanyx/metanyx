Running Ansible to provision the metanyx
----------------------------------------

#### First, install ansible. 
You can just clone their repo and source an environment file

```
git clone --recursive https://github.com/ansible/ansible.git ~/ansible
source ~/ansible/hacking/env-setup
```

otherwise see the [Ansible documentation](http://docs.ansible.com/intro_installation.html)

#### Change into the ansible directory within the metanyx repo
```
cd ansible
```

#### Create the variables file
```
mkdir group_vars
cat > group_vars/torproxy << __CONF__
target_hw: <olimex|beaglebone>
wpa_ssid: <your-ssid-or-leave-this-here>
wpa_psk: <your-psk-or-leave-this-here>
ap_enable: no
dns_servers: 
  - <dns_server_1>
  - <dns_server_2>
__CONF__
```
You'll want to edit those variables, which I'd do with a command like:
```
vi group_vars/torproxy
```

#### Edit the IP address of the board you are flashing.

```
vi inventory
```

This shouldn't need changing for a Beagle Bone Black with direct connection to your computer.
If you're running something which has DHCP'd to your local network you'll need to update the IP

#### Finally, run the playbook
```
ansible-playbook playbook.yml -i inventory -k
```
