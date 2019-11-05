#!/bin/sh
rm -r target/*
mkdir target
lua luapreproc.lua module/init.lua target/init.lua
cp -r exec/ service/ lib/ target/
