#                   _                            
#                  | |                           
#    _ __ ___   ___| |_ __ _ _ __  _   ___  __   
#   | '_ ' _ \ / _ \ __/ _' | '_ \| | | \ \/ /   
#   | | | | | |  __/ || (_| | | | | |_| |>  <    
#   |_| |_| |_|\___|\__\__'_|_| |_|\__' /_/\_\   
#                                   __/ |        
#                                  |___/         
#                                                
#
#                                                
#Building an SD image for the Olimex OLinuXino A20 LIME 
#------------------------------------------------------                                               
#
#This has been written for a Debian sid host. For other OS's you'd need to set up the 
#Sunxi toolchain, as per http://linux-sunxi.org/Toolchain
#
#Perform all steps as an unprivileged local user, except where noted

## Set up the host computer

#First, set up a working variable to point to where the metanyx repo has been cloned,
#for example:

echo "DO NOT USE THIS IT'S A WIP. WIP IT GOOD."
exit 1

REPO=~/dev/metanyx

#Enable armhf architecture

sudo dpkg --add-architecture armhf


#Update your apt cache

sudo apt-get update

#Install dependenies

#*(I had to install libmpc from source before I could complete the following apt install)*

sudo apt-get install gcc-4.7-arm-linux-gnueabihf ncurses-dev build-essential git debootstrap u-boot-tools libusb-1.0-0-dev

#Link gcc-4.7-arm-linux-gnueabihf binaries.

mkdir ~/bin
cd ~/bin
for i in /usr/bin/arm-linux-gnueabihf*-4.7 ; do j=${i##/usr/bin/}; ln -s $i ${j%%-4.7} ; done

#Create a local directory to work in.

mkdir ~/metanyx-img
cd ~/metanyx-img

## Uboot

#Clone u-boot-sunxi repo

git clone -b sunxi https://github.com/linux-sunxi/u-boot-sunxi.git
cd u-boot-sunxi/

#Make u-boot

make A20-OLinuXino-Lime_config ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf-
make ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf-

#Check that things look right, and then go back to your working directory

ls u-boot.bin u-boot-sunxi-with-spl.bin spl/sunxi-spl.bin
#spl/sunxi-spl.bin  u-boot.bin  u-boot-sunxi-with-spl.bin

cd ..

## script.bin

#This step is optional, I provide script.bin but you can generate your own.

git clone https://github.com/linux-sunxi/sunxi-tools.git
cd sunxi-tools/
make
./fex2bin $REPO/sdimage/src/script.fex $REPO/sdimage/src/script.bin
cd ..

## Kernel


git clone https://github.com/linux-sunxi/linux-sunxi
cd linux-sunxi
cp $REPO/sdimage/src/spi-sun7i.c drivers/spi/
cp $REPO/sdimage/src/SPI.patch ./
patch -p0 < SPI.patch
cp $REPO/sdimage/src/kernel.config arch/arm/configs/metanyx_defconfig
make ARCH=arm metanyx_defconfig


#Not necessary - you can alter kernel options tho

make ARCH=arm menuconfig

#Make uImage

make -j4 ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- uImage


#It will output like:
#
#
#<snip>
#Image Name:   Linux-3.4.103+
#Created:      Sun Oct 19 16:37:25 2014
#Image Type:   ARM Linux Kernel Image (uncompressed)
#Data Size:    4583904 Bytes = 4476.47 kB = 4.37 MB
#Load Address: 40008000
#Entry Point:  40008000
#  Image arch/arm/boot/uImage is ready
#

#Make modules


make -j4 ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- INSTALL_MOD_PATH=out modules
make -j4 ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- INSTALL_MOD_PATH=out modules_install


#If you get an error such as 

#`make[2]: *** No rule to make target `/lib/firmware/./', needed by
#`/lib/firmware/ti_3410.fw'.  Stop. ` 

#refer to the fix at
#http://lkml.org/lkml/2012/8/8/385

cd ..

## Partition and Format SD Card

### Partitioning

echo -e "n\np\n1\n\n+16M\nn\np\n2\n\n+1400M\nw\nq" | sudo fdisk /dev/sdX

### Format the partitions

#The first partition should be vfat as this is the filesystem which the Allwinner bootloader understands

sudo mkfs.vfat /dev/sdX1

#The second should be a Linux EXT3 filesystem

sudo mkfs.ext3 /dev/sdX2

## Write the bootloader

sudo dd if=u-boot-sunxi/u-boot-sunxi-with-spl.bin of=/dev/sdX bs=1024 seek=8

## Write kernel uImage you built to the SD card


sudo mount /dev/sdX1 /mnt/
sudo cp linux-sunxi/arch/arm/boot/uImage /mnt/


## Write script.bin file


sudo cp $REPO/sdimage/src/script.bin /mnt/
sync
sudo umount /mnt/


rootfs() {
  ## Debian rootfs
  #Refer to http://olimex.wordpress.com/2014/07/21/how-to-create-bare-minimum-debian-wheezy-rootfs-from-scratch/

  #Install dependencies
  sudo apt-get -y install qemu-user-static debootstrap binfmt-support

  mkdir rootfs
  sudo debootstrap --arch=armhf --foreign jessie rootfs
  sudo cp /usr/bin/qemu-arm-static rootfs/usr/bin/
  sudo cp /etc/resolv.conf rootfs/etc
  sudo chroot rootfs

  export distro=jessie
  export LANG=C
  /debootstrap/debootstrap --second-stage

  cat <<EOT > /etc/sources.list
  deb http://http.debian.net/debian jessie main
  deb-src http://http.debian.net/debian jessie main

  deb http://http.debian.net/debian jessie-updates main
  deb-src http://http.debian.net/debian jessie-updates main

  deb http://security.debian.org/ jessie/updates main
  deb-src http://security.debian.org/ jessie/updates main
  EOT

  apt-get update
  apt-get install -y -f locales dialog openssh-server python wpasupplicant

  # Set a password here
  passwd

  cat <<EOT >> /etc/network/interfaces
  auto eth0
  allow-hotplug eth0
  iface eth0 inet dhcp
  EOT

  echo 'debian' > /etc/hostname
  echo 'sunxi_emac' >> /etc/modules
  echo T0:2345:respawn:/sbin/getty -L ttyS0 115200 vt100 >> /etc/inittab
  sed -i 's/PermitRootLogin without-password/PermitRootLogin yes/' /etc/ssh/sshd_config
  rm -f /var/cache/apt/archives/*
  rm -rf lib/modules/*
  mkdir lib/modules
  rm -rf lib/firmware/
  exit

  sudo rm rootfs/etc/resolv.conf
  sudo rm rootfs/usr/bin/qemu-arm-static
}

sudo mount /dev/sdX2 /mnt
sudo cp -a rootfs/* /mnt/
sudo cp -rfv linux-sunxi/out/lib/modules/3.4.103+ /mnt/lib/modules/
sudo cp -rfv linux-sunxi/out/lib/firmware/ /mnt/lib/

git clone http://git.kernel.org/pub/scm/linux/kernel/git/firmware/linux-firmware.git
sudo cp -a linux-firmware/rtlwifi /mnt/lib/firmware/
sudo cp linux-firmware/rt28* /mnt/lib/firmware/

sync
sudo umount /mnt/
sudo eject /dec/sdX



## Eject SD image, insert into LIME board, and boot

#Your unit will obtain an address via DHCP over the ethernet port

#default username/password is : **root / metanyx** and SSH is listening on port 22

#Proceed to install metanyx to your unit via the [ansible-playbook](../ansible/README.md)


## References
#http://linux-sunxi.org/Toolchain#Debian

#https://github.com/OLIMEX/OLINUXINO/tree/master/SOFTWARE/A20/A20-build
