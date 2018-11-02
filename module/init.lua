os.spawn(function() print(pcall(function()
print(_OSVERSION,tostring(math.floor(computer.totalMemory()/1024)).."K memory")
local f = fs.open("/boot/init.txt","rb")
local fc = f:read("*a")
f:close()
for line in fc:gmatch("[^\n]+") do
 print("Starting service "..line)
 spawnfile("/boot/service/"..line)
end
for k,v in pairs(fd) do
 if v.t == "t" then
  tTasks[cPid].t = k
  print("Spawning a shell for terminal #"..tostring(k))
  spawnfile("/boot/exec/shell.lua","shell #"..tostring(k))
 end
end
end)) end,"init")
