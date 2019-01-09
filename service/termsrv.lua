print(pcall(function()
local minitel = require "minitel"
local port = 22
local logfile = "/boot/termsrv.log"

if logfile then
 local log = io.open(logfile,"a")
 os.setenv("t",log.fd)
end
while true do
 local sock = minitel.listen(port)
 print(string.format("[%s] Connection from %s:%d",os.date("%Y-%m-%d %H:%M"),sock.addr,sock.port))
 os.spawn(function() _G.worked = {pcall(function()
  local fdi, fdo = io.newfd()
  function fdo.read(d)
    return sock:read(d)
  end
  function fdo.write(d)
    return sock:write(d)
  end
  function fdo.close()
   sock:close()
  end
  fd[fdi] = fdo
  os.setenv("t",fdi)
  sock:write(string.format("Connected to %s on port %d\n",computer.address():sub(1,8),sock.port))
  local pid = spawnfile("/boot/exec/shell.lua",string.format("shell [%s:%d]",sock.addr,sock.port))
  repeat
   coroutine.yield()
  until sock.state ~= "open" or not tTasks[pid]
  fdo.close()
  sock:close()
  os.kill(pid)
 end)} end,string.format("remote login [%s:%d]",sock.addr,sock.port))
end
end))
