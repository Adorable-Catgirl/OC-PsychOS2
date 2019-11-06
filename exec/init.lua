xpcall(function()
os.setenv("PWD","/boot")
os.spawnfile("/boot/service/getty.lua")
coroutine.yield()
for k,v in pairs(fs.list("/dev/")) do
 if v:sub(1,3) == "tty" then
  dprint(tostring(io.input("/dev/"..v)))
  dprint(tostring(io.output("/dev/"..v)))
  io.write(_OSVERSION.." - "..tostring(math.floor(computer.totalMemory()/1024)).."K RAM")
  os.spawnfile("/boot/exec/shell.lua")
 end
end
while true do
 coroutine.yield()
end
end,function(e) dprint(e) end,"init")
