#!/usr/bin/bash
set -e

# Install the needed tools
sudo apt install build-essential binutils bzip2 git make libncurses-dev flex \
bison bc cpio libelf-dev libssl-dev qemu-system grub-pc-bin

# Make directory structure needed for the build
mkdir -p boot boot/image boot/image/dev boot/image/proc boot/image/sys

# Download the linux kernel source and compile
git clone --depth 1 https://github.com/torvalds/linux
cp x.config linux/.config
cd linux
make -j${nproc}
cp arch/x86/boot/bzImage ../boot/
cd ..

# Download the busybox source and compile
git clone --depth 1 https://git.busybox.net/busybox
cd busybox
make defconfig
sed -i '/# CONFIG_STATIC is not set/c\CONFIG_STATIC=y' .config
sed -i '/CONFIG_TC=y/c\CONFIG_TC=n' .config
make -j$(nproc)
make CONFIG_PREFIX=../boot/image install
cd ../boot/image

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

# Build the boot disk image
dd if=/dev/zero of=boot.img bs=1M count=250
echo 'start=2048, size=509952, type=83, bootable' | sudo sfdisk boot.img
sudo losetup /dev/loop0 boot.img
sudo losetup /dev/loop1 boot.img -o 1M
sudo mkfs.ext4 /dev/loop1
sudo mkdir /mnt/boot
sudo mount /dev/loop1 /mnt/boot
sudo cp bzImage init.cpio /mnt/boot
sudo grub-install --target=i386-pc --root-directory=/mnt/boot --no-floppy --modules="normal part_msdos ext2 multiboot" /dev/loop0
echo "menuentry 'Linux' {" > grub.cfg
echo "        set root='(hd0,1)'" >> grub.cfg
echo "        linux /bzImage" >> grub.cfg
echo "        initrd /init.cpio" >> grub.cfg
echo "}" >> grub.cfg
sudo cp grub.cfg /mnt/boot/boot/grub/grub.cfg

# Clean up
sudo umount /dev/loop1
sudo losetup -d /dev/loop1
sudo losetup -d /dev/loop0
sudo rmdir /mnt/boot

echo "Done"
