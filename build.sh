#!/usr/bin/env bash
mkdir build
cd module
cat sched.lua syslog.lua vt100.lua fs.lua iofs.lua loadfile.lua vt-task.lua io.lua createterms.lua init.lua > ../build/psychos.lua
cd ..
echo '_OSVERSION="PsychOS 2.0a0"' >> build/*
echo sched\(\) >> build/*
