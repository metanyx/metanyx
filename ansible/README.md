Running Ansible to provision the TOR-Bone
-----------------------------------------

#### First, install ansible. 
You can just clone their repo and source an environment file

```
git clone https://github.com/ansible/ansible.git ~/ansible
source ~/ansible/hacking/env-setup
```

#### Change into the ansible directory within the TOR-Bone repo
```
cd ansible
```

#### Create the variables file
```
mkdir group_vars
cat > group_vars/torproxy << __CONF__
external_interface: wlan0
wpa_ssid: <your-ssid>
wpa_psk: <your_psk>
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
vi metanyx 
```

This shouldn't need changing for a Beagle Bone Black with direct connection to your computer.
If you're running something which has DHCP'd to your local network you'll need to update the IP

#### Finally, run the playbook
```
ansible-playbook playbook.yml -i metanyx
```
