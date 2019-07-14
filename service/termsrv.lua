print(pcall(function()
local minitel = require "minitel"
local port = 22
--local logfile = "/boot/termsrv.log"

if logfile then
 local log = io.open(logfile,"a")
 os.setenv("t",log.fd)
end
local function nextvty()
 local vtyn = -1
 repeat
  vtyn = vtyn + 1
 until not fs.exists("/iofs/vty"..tostring(vtyn))
 return "vty"..tostring(vtyn)
end
while true do
 local sock = minitel.listen(port)
 print(string.format("[%s] Connection from %s:%d",os.date("%Y-%m-%d %H:%M"),sock.addr,sock.port))
 os.spawn(function() _G.worked = {pcall(function()
  local vtyf = nextvty()
  local fdo = {}
  function fdo.read(d)
    return sock:read(d)
  end
  function fdo.write(d)
    return sock:write(d)
  end
  function fdo.close()
   sock:close()
  end
  iofs.register(vtyf,function() return fdo.read, fdo.write, fdo.close end)
  local f = io.open("/iofs/"..vtyf,"rw")
  print(vtyf, f.fd)
  local ot = os.getenv("t")
  os.setenv("t",f.fd)
  sock:write(string.format("Connected to %s on port %d\n",computer.address():sub(1,8),sock.port))
  local pid = spawnfile("/boot/exec/shell.lua",string.format("shell [%s:%d]",sock.addr,sock.port))
  repeat
   coroutine.yield()
  until sock.state ~= "open" or not tTasks[pid]
  f:close()
  sock:close()
  os.kill(pid)
  os.setenv("t",ot)
  print(string.format("Session %s:%d ended",sock.addr,sock.port))
 end)} end,string.format("remote login [%s:%d]",sock.addr,sock.port))
end
end))
