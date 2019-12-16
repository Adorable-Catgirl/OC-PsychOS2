_OSVERSION="PsychOS $[{PSYCHOS_VMAJ}].$[{PSYCHOS_VMIN}]-$[[git rev-parse --short HEAD]]"
_LCVERSION="LuaComp $[[luacomp --version]] (-m$[{LUACOMP_MINIFIER}])"
@[[local fh = io.popen("ls module", "r")]]
@[[for line in fh:lines() do]]
	@[[if line:match("%d%d_.+") then]]
--#include @[{"module/"..line}]
	@[[end]]
@[[end]]
---#include "module/chatbox-dprint.lua"
---#include "module/syslog.lua"
---#include "module/sched.lua"
---#include "module/osutil.lua"
---#include "module/fs.lua"
---#include "module/newio.lua"
---#include "module/devfs.lua"
---#include "module/devfs/syslog.lua"
---#include "module/vt-task.lua"
---#include "module/loadfile.lua"
os.spawnfile("/boot/exec/init.lua")

os.sched()
