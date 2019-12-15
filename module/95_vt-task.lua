do
--#include "module/vt100.lua"
function vtemu(gpua,scra) -- creates a process to handle the GPU and screen address combination *gpua*/*scra*. Returns read, write and "close" functions.
 local gpu = component.proxy(gpua)
 gpu.bind(scra)
 local write = vt100emu(gpu)
 local kba = {}
 for k,v in ipairs(component.invoke(scra,"getKeyboards")) do
  kba[v]=true
 end
 local buf = ""
 os.spawn(function() dprint(pcall(function()
  while true do
   local ty,ka,ch = coroutine.yield()
   if ty == "key_down" and kba[ka] then
    if ch == 13 then ch = 10 end
    if ch == 8 then
     if buf:len() > 0 then
      write("\8 \8")
      buf = buf:sub(1,-2)
     end
    elseif ch > 0 then
     write(string.char(ch))
     buf=buf..string.char(ch)
    end
   end
  end
 end)) end,string.format("ttyd[%s:%s]",gpua:sub(1,8),scra:sub(1,8)))
 local function bread()
  while not buf:find("\n") do
   coroutine.yield()
  end
  local n = buf:find("\n")
  r, buf = buf:sub(1,n-1), buf:sub(n+1)
  return r
 end
 return bread, write, function() io.write("\27[2J\27[H") end
end
end