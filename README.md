# Make custom boot image

sudo apt install bzip2 git make gcc libncurses-dev flex bison bc cpio libelf-dev libssl-dev syslinux dosfstools qemu-system

mkdir boot-image

cd boot-image

mkdir boot

mkdir mnt

mkdir boot/initramfs

mkdir -p boot/initramfs/dev boot/initramfs/proc boot/initramfs/sys

git clone --depth 1 https://github.com/torvalds/linux.git

cd linux

make menuconfig (check to make sure 64 bit is enabled)

make -j 8

cp arch/x86/boot/bzImage ../boot/

cd ..

git clone --depth 1 https://git.busybox.net/busybox

cd busybox

make menuconfig (Setup > Build Options > Build static)

make -j 8

make CONFIG_PREFIX=../boot/initramfs install

cd ../boot/initramfs

nano init

```
#!/bin/sh
mount -t sysfs sysfs /sys
mount -t proc proc /proc
mount -t devtmpfs udev /dev
/bin/sh
poweroff -f
```
chmod 777 init

rm linuxrc

sudo chown -R root:root *

find . | cpio -o -H newc > ../init.cpio

cd ..

nano syslinux.cfg

```
DEFAULT linux
LABEL linux
SAY Now booting
KERNEL /bzImage
APPEND initrd=/init.cpio console=ttyS0
```

dd if=/dev/zero of=boot.img bs=1M count=50

sudo mkfs -t fat boot.img

sudo mount boot.img mnt

sudo cp bzImage init.cpio syslinux.cfg mnt/

sudo chown -R root:root mnt/*

sudo umount mnt

syslinux boot.img

qemu-system-x86_64 boot.img -nographic
