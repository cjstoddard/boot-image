#!/bin/sh
set -e

# Install the needed tools
sudo apt install build-essential bzip2 git make libncurses-dev flex bison bc cpio libelf-dev libssl-dev dosfstools qemu-system extlinux

# Make directory structure needed for the build
mkdir -p boot boot/initramfs boot/initramfs/dev boot/initramfs/proc boot/initramfs/sys

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

# make the extlinux configuration file
echo "DEFAULT linux" > extlinux.conf
echo "LABEL linux" >> extlinux.conf
echo "SAY Now booting" >> extlinux.conf
echo "KERNEL /bzImage" >> extlinux.conf
echo "APPEND initrd=/init.cpio console=ttyS0" >> extlinux.conf

# build the boot image
dd if=/dev/zero of=boot.img bs=1M count=250
sudo mkfs.ext2 boot.img
sudo mkdir /mnt/boot
sudo mount boot.img /mnt/boot
sudo cp bzImage init.cpio extlinux.conf /mnt/boot/
sudo extlinux --install /mnt/boot
sudo umount /mnt/boot
sudo rmdir /mnt/boot

echo "Done"