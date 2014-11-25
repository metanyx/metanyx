```
                   _                            
                  | |                           
    _ __ ___   ___| |_ __ _ _ __  _   ___  __   
   | '_ ' _ \ / _ \ __/ _' | '_ \| | | \ \/ /   
   | | | | | |  __/ || (_| | | | | |_| |>  <    
   |_| |_| |_|\___|\__\__'_|_| |_|\__' /_/\_\   
                                   __/ |        
                                  |___/         
```
                                                

                                                
Building an SD image for the Olimex OLinuXino A20 LIME 
------------------------------------------------------                                               

This has been written for a Debian sid host. For other OS's you'd need to set up the 
Sunxi toolchain, as per http://linux-sunxi.org/Toolchain

Perform all steps as an unprivileged local user, except where noted

## Set up the host computer

First, set up a working variable to point to where the metanyx repo has been cloned,
for example:

    REPO=~/dev/metanyx

Enable armhf architecture

    sudo dpkg --add-architecture armhf


Update your apt cache

    sudo apt-get update

Install dependenies

*(I had to install libmpc from source before I could complete the following apt install)*

```
sudo apt-get install gcc-4.7-arm-linux-gnueabihf ncurses-dev build-essential git \
debootstrap u-boot-tools libusb-1.0-0-dev
```

Link gcc-4.7-arm-linux-gnueabihf binaries.

```
mkdir ~/bin
cd ~/bin
for i in /usr/bin/arm-linux-gnueabihf*-4.7 ; do j=${i##/usr/bin/}; ln -s $i ${j%%-4.7} ; done
```

Create a local directory to work in.

```
mkdir ~/metanyx-img
cd ~/metanyx-img
```

## Uboot

Clone u-boot-sunxi repo

```
git clone -b sunxi https://github.com/linux-sunxi/u-boot-sunxi.git
cd u-boot-sunxi/
```
Make u-boot

```
make A20-OLinuXino-Lime_config ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf-
make ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf-
```

Check that things look right, and then go back to your working directory

```
ls u-boot.bin u-boot-sunxi-with-spl.bin spl/sunxi-spl.bin
  spl/sunxi-spl.bin  u-boot.bin  u-boot-sunxi-with-spl.bin

cd ..
```

## script.bin

This step is optional, I provide script.bin but you can generate your own.

```
git clone https://github.com/linux-sunxi/sunxi-tools.git
cd sunxi-tools/
make
./fex2bin $REPO/sdimage/src/script.fex $REPO/sdimage/src/script.bin
cd ..
```

## Kernel

```
git clone https://github.com/linux-sunxi/linux-sunxi
cd linux-sunxi
cp $REPO/sdimage/src/spi-sun7i.c drivers/spi/
cp $REPO/sdimage/src/SPI.patch ./
patch -p0 < SPI.patch
cp $REPO/sdimage/src/kernel.config arch/arm/configs/metanyx_defconfig
make ARCH=arm metanyx_defconfig
```

Not necessary - you can alter kernel options tho

    make ARCH=arm menuconfig

Make uImage

    make -j4 ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- uImage

It will output like:

```
<snip>
Image Name:   Linux-3.4.103+
Created:      Sun Oct 19 16:37:25 2014
Image Type:   ARM Linux Kernel Image (uncompressed)
Data Size:    4583904 Bytes = 4476.47 kB = 4.37 MB
Load Address: 40008000
Entry Point:  40008000
  Image arch/arm/boot/uImage is ready
```

```
make -j4 ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- INSTALL_MOD_PATH=out modules
make -j4 ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- INSTALL_MOD_PATH=out modules_install
cd ..
```

## Format SD Card

    sudo fdisk /dev/sdX

*p will list your partitions*

if there are already partitions on your card do:

*d enter 1*
if you have more than one partitition press d while delete them all

create the first partition, starting from 2048
*n enter p enter 1 enter enter +16M*

create second partition
*n enter p enter 2 enter enter enter*

then list the created partitions:
*p enter*
if you did everything correctly on 4GB card you should see something like:

```
Disk /dev/sdg: 3980 MB, 3980394496 bytes
123 heads, 62 sectors/track, 1019 cylinders, total 7774208 sectors
Units = sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disk identifier: 0x00000000

   Device Boot      Start         End      Blocks   Id  System
/dev/sdg1            2048       34815       16384   83  Linux
/dev/sdg2           34816     7774207     3869696   83  Linux
```

*press w*


Format the partitions

The first partition should be vfat as this is FS which the Allwinner bootloader understands

    sudo mkfs.vfat /dev/sdX1

the second should be normal Linux EXT3 FS

    sudo mkfs.ext3 /dev/sdX2

## Write the Uboot and u-boot-sunxi-with-spl.bin

    sudo dd if=u-boot-sunxi/u-boot-sunxi-with-spl.bin of=/dev/sdc bs=1024 seek=8

## Write kernel uImage you build to the SD-card

```
sudo mount /dev/sdX1 /mnt/
sudo cp linux-sunxi/arch/arm/boot/uImage /mnt/
```

## Write script.bin file

```
sudo cp $REPO/sdimage/src/script.bin /mnt/
sync
sudo umount /mnt/
```

## Debian rootfs

Refer to http://olimex.wordpress.com/2014/07/21/how-to-create-bare-minimum-debian-wheezy-rootfs-from-scratch/

```
sudo apt-get install qemu-user-static debootstrap binfmt-support
mkdir rootfs
sudo debootstrap --arch=armhf --foreign wheezy rootfs
sudo cp /usr/bin/qemu-arm-static rootfs/usr/bin/
sudo cp /etc/resolv.conf rootfs/etc

*** got to here ***

sudo echo "sunxi_emac" >> rootfs/etc/modules
sudo mount /dev/sdX2 /mnt
sudo cp -a rootfs/* /mnt/
sudo rm -rf /mnt/lib/modules/*
sudo mkdir /mnt/lib/modules/*
sudo cp -rfv linux-sunxi/out/lib/modules/3.4.103+ /mnt/lib/modules/
sudo rm -rf /mnt/lib/firmware/
sudo cp -rfv linux-sunxi/out/lib/firmware/ /mnt/lib/
sync
sudo umount /mnt/
```

## Eject SD image, insert into LIME board, connect UART and boot

default username/password is : **root / metanyx**



# Some more notes for me to move elsewhere

### Kernel configs to add in make menuconfig:


CONFIG_HAVE_AOUT
CONFIG_MTD
CONFIG_SUNXI_EMAC
CONFIG_ATH9K_RATE_CONTROL
CONFIG_RTL8192CU



### loading wifi firmware:

```
git clone http://git.kernel.org/pub/scm/linux/kernel/git/firmware/linux-firmware.git
cp -a linux-firmware/rtlwifi /lib/firmware/
cp linux-firmware/rt28* /lib/firmware/
```


###Access point:

    sudo apt-get install hostapd

add interface=wlan1 to /etc/dnsmasq.conf
add to /etc/network/interfaces:

```
# Access point interface
auto wlan1
allow-hotplug wlan1
iface wlan1 inet static
    address 192.168.6.2
    netmask 255.255.255.0
    network 192.168.6.0
```

    vi /etc/hostapd/hostapd.conf:

enter stuff...

    vi /etc/default/hostapd

*DAEMON_CONF="/etc/hostapd/hostapd.conf"*

#### For edimax:
```
git clone https://github.com/jenssegers/RTL8188-hostapd
cd RTL8188-hostapd/hostapd
```

```
make
mv hostapd /usr/sbin/hostapd
```

## References
http://linux-sunxi.org/Toolchain#Debian
