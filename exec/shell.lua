print(pcall(function()
local shenv = {}
function shenv.quit()
 os.setenv("run",nil)
end
shenv.cd = os.chdir
shenv.mkdir = fs.makeDirectory
setmetatable(shenv,{__index=function(_,k)
 if _G[k] then
  return _G[k]
 elseif fs.exists("/boot/exec/"..k..".lua") then
  --[[
  local rqid = string.format("shell-%d",math.random(1,99999))
  return function(...)
   local tA = {...}
   local pid = os.spawn(function() computer.pushSignal(rqid,pcall(loadfile("/boot/exec/"..k..".lua"),table.unpack(tA))) end,"/boot/exec/"..k..".lua")
   local tE = {}
   repeat
    tE = {coroutine.yield()}
    if tE[1] == rqid then
     table.remove(tE,1)
     if tE[1] == true then
      table.remove(tE,1)
     end
     return table.unpack(tE)
    end
   until tTasks[pid] == nil
  end
  ]]--
  return loadfile("/boot/exec/"..k..".lua")
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
