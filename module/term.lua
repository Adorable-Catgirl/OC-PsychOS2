--#include "module/vt-task.lua"
do
local r,w = vtemu(component.list("gpu")(),component.list("screen")())
devfs.register("tty0", function() return r,w,function() end end)
end
