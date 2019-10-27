--#include "module/syslog.lua"
--#include "module/sched.lua"
--#include "module/buffer.lua"
--#include "module/fs.lua"
--#include "module/io.lua"
--#include "module/devfs.lua"
--#include "module/devfs/syslog.lua"
--#include "module/loadfile.lua"
--#include "module/term.lua"
os.spawnfile("/boot/exec/init.lua","init")

os.sched()
