--#include "module/chatbox-dprint.lua"
--#include "module/syslog.lua"
--#include "module/sched.lua"
--#include "module/fs.lua"
--#include "module/newio.lua"
--#include "module/devfs.lua"
--#include "module/devfs/syslog.lua"
--#include "module/vt-task.lua"
--#include "module/loadfile.lua"
os.spawnfile("/boot/exec/init.lua")

os.sched()
