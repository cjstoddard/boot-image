# Make custom boot image

This is instructions for making a very simple bootable Linux image that can be booted using Qemu. This is probably as light a linux ditro as is possible.
You can either go through the process manually by following the instructions in the step-by-step.txt file or you can run the build-boot.sh shell script to automate the process.
The boot-666.img.tar.gz is a ready built image using the 6.6.6 Linux kernel.
Regardless of how you get the image, once you have it, you can boot it with the following command, assuming you have qemu installed.

qemu-system-x86_64 boot.img -nographic

Disclaimer: This software is provided "AS IS", without warranty of any kind, express or implied, including but not limited to warranties of merchantability, fitness for a paticular purpose and nonifringment. In no event shall the author or copyright holders be liable for any claim, damages or other liability, whether in an action of contract, tort or otherwise, arising from, out of or in connection with the software or the use or other dealings in the software.
