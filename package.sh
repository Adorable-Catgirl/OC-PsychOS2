#!/bin/bash
rm -r psychos
mkdir psychos
cp -r exec/ lib/ service/ psychos/
cp build/psychos.lua psychos/init.lua
cp default-init.txt psychos/init.txt
find psychos/ | cpio -oHbin > psychos.cpio
cd psychos
find | cpio -oHbin > ../psychos-tarbomb.cpio
