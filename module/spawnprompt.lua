os.spawn(function()
print(_OSVERSION,tostring(computer.totalMemory()/1024).."K memory")
for k,v in pairs(fd) do
 if v.t == "t" then
  os.setenv("t") = k
  print("Spawning Lua prompt for "..tostring(k))
  os.setenv("PWD","/boot")
  os.spawn(function() print(pcall(function() while true do
   io.write(_VERSION.."> ")
   tResult = {pcall(load(io.read()))}
   for k,v in pairs(tResult) do
    print(v)
   end
  end end)) end,"lua prompt")
 end
end end,"init")
