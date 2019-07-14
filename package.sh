#!/bin/bash
rm -r psychos
mkdir psychos
cp -r exec/ lib/ service/ psychos/
cp build/psychos.lua psychos/init.lua
tree -if psychos/ | cpio -oHbin > psychos.cpio
