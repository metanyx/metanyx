1. Setup of the toolchain
-------------------------

You should make sure you have the tools for building the Linux Kernel and install them if you don’t have them. To install new software you should be with super user rights on your Linux machine, so do this type in a terminal.

    sudo su -

you will be asked for your password and then your prompt will change to # which means you are now the super user, all future commands should be run in this mode.

First update apt-get links by typing

    apt-get update

Install the toolchain by typing the following.

    apt-get install gcc-4.7-arm-linux-gnueabihf ncurses-dev uboot-mkimage build-essential git

This will install: GCC compiler used to compile the kernal, The kernel config menu
uboot make image which is required to allow the SD card to book into the linux image, Git which allows you to download from the github which holds source code for some of the system, Some other tools for building the kernel.

Note that if you use debian may be you will need to add

deb http://www.emdebian.org/debian squeeze main

in the file below:

/etc/apt/sources.list

after the installation you now have all tools to make your very own metanyx image!




References
----------
http://olimex.wordpress.com/2013/12/13/building-debian-linux-image-for-a10-olinuxino-lime-with-kernel-3-4-67/
