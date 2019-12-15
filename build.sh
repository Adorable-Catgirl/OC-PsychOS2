#!/bin/sh

# Remember to bump the version number, asshole.
export PSYCHOS_VMAJ=2
export PSYCHOS_VMIN=0a1

# Don't touch anything down here
rm -r target/*
mkdir target &>/dev/null
mkdir target/cfg
#lua luapreproc.lua module/init.lua target/init.lua
luacomp -Otarget/init.lua module/init.lua
echo _OSVERSION=\"PsychOS 2.0a1-$(git rev-parse --short HEAD)\" > target/version.lua
# cat target/version.lua target/init.lua > target/tinit.lua
# mv target/tinit.lua target/init.lua
cp -r exec/ service/ lib/ target/
cp default-init.txt target/cfg/init.txt
lua finddesc.lua $(find module/ -type f) $(find lib/ -type f) > apidoc.md