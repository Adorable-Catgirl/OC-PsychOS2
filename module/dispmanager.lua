do
local tG,ttyn = {}, 0

local function checkUnused(addr) -- returns false if a screen *addr* is already allocated to a GPU
 for k,v in pairs(tG) do
  if v == addr then
   return false
  end
 end
 return true
end
local function findNextDisplay() -- finds the next available screen, or nil if there are no available screens
 for a,_ in component.list("screen") do
  if checkUnused(a) then
   return a
  end
 end
 return nil
end

for file in ipairs(fs.list("/boot/cfg/disp/")) do -- allows files in /boot/cfg/disp with filenames as GPU addresses to bind to specific screens
 if component.proxy(file) then
  local f = io.open("/boot/cfg/disp/"..file)
  if f then
   local sA = file:read()
   if checkUnused(sA) then
    tG[file] = sA
   end
   f:close()
  end
 end
end

for a,_ in component.list("gpu") do -- allocate a screen to every unused GPU
 tG[a] = findNextDisplay()
end

for gpu,screen in pairs(tG) do
 dprint(gpu,screen)
 local r,w = vtemu(gpu,screen)
 iofs.register("tty"..tostring(ttyn),function() return r,w,function() w("\27[2J\27[H") end end)
 local f = io.open("/iofs/tty"..tostring(ttyn),"rw")
 fd[f.fd].t = "t"
 ttyn = ttyn + 1
end
do
 iofs.register("syslog",function() return function() return "" end, function(msg) syslog(msg,nil,tTasks[cPid].n) end, function() return true end end)
end
if #fd < 1 then
 io.open("/iofs/syslog","rw")
end
end
