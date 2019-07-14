os.spawn(function() print(pcall(function()
print(_OSVERSION,tostring(math.floor(computer.totalMemory()/1024)).."K memory")
os.setenv("PWD","/boot")
local f = fs.open("/boot/init.txt","rb")
if f then
 local fc = f:read("*a")
 f:close()
 for line in fc:gmatch("[^\n]+") do
  print("Starting service "..line)
  spawnfile("/boot/service/"..line,line)
 end
end
for k,v in pairs(fd) do
 if v.t == "t" then
  os.setenv("t",k)
  print("Spawning a shell for terminal #"..tostring(k))
  spawnfile("/boot/exec/shell.lua","shell [local:"..tostring(k).."]")
 end
end
end)) end,"init")
