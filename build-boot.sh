#!/bin/sh

# Makes the script stop when it encounters an error
set -e

# Install the needed tools
sudo apt install build-essential bzip2 git make libncurses-dev flex bison bc cpio libelf-dev libssl-dev syslinux dosfstools qemu-system

# Make directory structure needed for the build
mkdir -p boot boot/mnt boot/initramfs boot/initramfs/dev boot/initramfs/proc boot/initramfs/sys

# Download the linux kernel source and compile
git clone --depth 1 https://github.com/torvalds/linux.git
cd linux
make defconfig
make -j 8
cp arch/x86/boot/bzImage ../boot/
cd ..

# Download the busybox source and compile
git clone --depth 1 https://git.busybox.net/busybox
cd busybox
make defconfig
sed -i '/# CONFIG_STATIC is not set/c\CONFIG_STATIC=y' .config
make -j 8
make CONFIG_PREFIX=../boot/initramfs install
cd ../boot/initramfs

# make the init file for loading the ram disk
echo "#!/bin/sh" > init
echo "mount -t sysfs sysfs /sys" >> init
echo "mount -t proc proc /proc" >> init
echo "mount -t devtmpfs udev /dev" >> init
echo "/bin/sh" >> init
echo "poweroff -f" >> init

# build the init.cpio ram disk file
chmod 777 init
rm linuxrc
sudo chown -R root:root *
find . | cpio -o -H newc > ../init.cpio
cd ..

# make the syslinux configuration file
echo "DEFAULT linux" > syslinux.cfg
echo "LABEL linux" >> syslinux.cfg
echo "SAY Now booting" >> syslinux.cfg
echo "KERNEL /bzImage" >> syslinux.cfg
echo "APPEND initrd=/init.cpio console=ttyS0" >> syslinux.cfg

# build the boot image
dd if=/dev/zero of=boot.img bs=1M count=50
sudo mkfs -t fat boot.img
sudo mount boot.img mnt
sudo cp bzImage init.cpio syslinux.cfg mnt/
sudo chown -R root:root mnt/*
sudo umount mnt

# make the boot image bootable
syslinux boot.img
