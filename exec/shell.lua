print(pcall(function()
local shenv = {}
function shenv.quit()
 os.setenv("run",nil)
end
setmetatable(shenv,{__index=function(_,k)
 if _G[k] then
  return _G[k]
 elseif fs.exists("/boot/exec/"..k..".lua") then
  return function(...)
   local tA = {...}
   local pid = os.spawn(function() loadfile("/boot/exec/"..k..".lua")(table.unpack(tA)) end,"/boot/exec/"..k..".lua")
   repeat
    coroutine.yield()
   until tTasks[pid] == nil
  end
 end
end})
print(_VERSION)
os.setenv("run",true)
while os.getenv("run") do
 io.write((os.getenv("PWD") or _VERSION).."> ")
 tResult = {pcall(load(io.read(),"shell","t",shenv))}
 if tResult[1] == true then table.remove(tResult,1) end
 for k,v in pairs(tResult) do
  print(v)
 end
end
end))
