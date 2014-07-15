TOR-Bone
========

A Transparent TOR proxy built on a Beagle Bone Black

How-to
------

_This presumes a fresh Beagle Bone Black rev C, which comes with Debian pre-installed._

#### Set up networking and SSH/console to the Beagle Bone

There are good guides to this already online, such as the BeagleBoard [getting started guide](http://beagleboard.org/Getting+Started)

I use Linux and found the following stepd to work:
- Download and run [mkudevrule.sh](http://beagleboard.org/static/Drivers/Linux/FTDI/mkudevrule.sh) from beagleboard.org.
- Plug the mini USB cable into the Beagle and then into your host system.  
Once powered up you should see a new network interface.
- Configure the new network interface with an ip, such as:
    ~~ifconfig eth1 192.168.7.1~~
- You should now be able to ssh to the Beagle:
    ~~ssh root@192.168.7.2~~

#### Run the provided ansible playbook
_coming soon_
