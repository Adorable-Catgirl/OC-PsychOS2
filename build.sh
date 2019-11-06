#!/bin/sh
rm -r target/*
mkdir target
lua luapreproc.lua module/init.lua target/init.lua
echo _OSVERSION=\"PsychOS 2.0a1-$(git rev-parse --short HEAD)\" > target/version.lua
cat target/version.lua target/init.lua > target/tinit.lua
mv target/tinit.lua target/init.lua
cp -r exec/ service/ lib/ target/
lua finddesc.lua $(find module/ -type f) $(find lib/ -type f) > apidoc.md
