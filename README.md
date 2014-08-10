TOR-Bone
========

The perfect gift for Fathers Day.

also: A Transparent TOR proxy built on a Beagle Bone Black.  

Presently this works, many of the times, but it's not without it's issues which I'm slowly ironing out.

How-to
------

In the beginning, I went ahead and removed the serial number sticker from the bone.

#### Flash an SD card with a Debian image

The latest image can be downloaded from http://beagleboard.org/latest-images

Be sure to verify the md5sum on the image.

    md5sum bone-debian-7.5-2014-05-14-2gb.img.xz

You can flash the image to the BBB from a linux system using dd

    unxz bone-debian-7.5-2014-05-14-2gb.img.xz 
    sudo dd if=bone-debian-7.5-2014-05-14-2gb.img of=/dev/<id>

Once burned, slot that sucker into the bone.

#### Set up networking and SSH to the Beagle Bone

There are good guides to this already online, such as the BeagleBoard [getting started guide](http://beagleboard.org/Getting+Started)

I use Linux and found the following steps to work:

- Download and run [mkudevrule.sh](http://beagleboard.org/static/Drivers/Linux/FTDI/mkudevrule.sh) from beagleboard.org (*NOTE that presently beagleboard.org is unavailable via SSL - I'm yet to raise this with them*)

- Plug the mini USB cable into the BeagleBone and then into your host system.  
Once powered up you should see a new network interface.

- Configure the new network interface with an ip, such as

    ifconfig eth1 192.168.7.1

- You should now be able to ssh to the BeagleBone

    ssh root@192.168.7.2

- Expand the filesystem to take up the remaining empty space on your SD card

    bash /opt/scripts/tools/grow_partition.sh 

- Reboot

#### Run the provided ansible playbook
[Instructions](https://github.com/auraltension/TOR-Bone/tree/master/ansible)

#### Reboot your new TOR-Bone
Just pull the power from the BeagleBone Black.

Once you've done this, plug the ethernet cable into your computer, and a wireless USB dongle into the BBB's 
USB port.  If you're feeling generous you could use an ethernet switch and share the darkness with your friends 
or neighbours.  You'll want to ensure any other connections to your computer are disabled, such as your local WiFi.

Then you can go ahead and plug it back in, it'll take about a minute to boot and give you an IP address.

#### Check that you're properly configured
Visit https://check.torproject.org/ to confirm that you are now surfing via TOR. Cowabunga!

Compatable Hardware
-------------------
The following wireless devices are considered stable when used as part of the TOR-Bone
* Alfa AWUS036NH USB WiFi

Known Issues
------------
See [issues](https://github.com/auraltension/TOR-Bone/issues)

Contact
-------
email: auraltension@riseup.net (PGP key can be found in /docs)
twitter: @auraltensn

