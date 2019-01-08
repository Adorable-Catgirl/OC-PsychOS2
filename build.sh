#!/usr/bin/env bash
cp ../OC-Minitel/minitel.lua service/minitel.lua
mkdir build
cd module
cat sched.lua vt100.lua fs.lua loadfile.lua vt-task.lua io.lua createterms.lua init.lua > ../build/psychos.lua
cd ..
echo '_OSVERSION="PsychOS 2.0a0"' >> build/*
echo sched\(\) >> build/*
