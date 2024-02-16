# Make custom boot image

This is a shell script that builds a very simple bootable Linux image that can be booted using Qemu. This is probably as light a linux ditro as is possible.

The boot-666.img.tar.gz is a ready built image using the 6.6.6 Linux kernel.

Once you have have built the image, you can boot it with the following command.

qemu-system-x86_64 boot.img -nographic

Keep in mind, this image is extlinux+kernel+busybox and is therefore nearly useless in its current form. It does not do anything beyond booting up. It is up to you to expand upon it and make something useful from it. My next step is going be to get it to boot off a USB drive or hard drive, after that I will probably add some actual programs like nano, calcurse and tmux.

Disclaimer: This software is provided "AS IS", without warranty of any kind, express or implied, including but not limited to warranties of merchantability, fitness for a paticular purpose and nonifringment. In no event shall the author or copyright holders be liable for any claim, damages or other liability, whether in an action of contract, tort or otherwise, arising from, out of or in connection with the software or the use or other dealings in the software.

Update 2/16/2024:
Switched from formatting the boot image as FAT32 to EXT2 and switch from using syslinux to extlinux for making the image bootable. 
