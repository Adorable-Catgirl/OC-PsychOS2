print(pcall(function()
local shenv = {}
function shenv.quit()
 os.setenv("run",nil)
end
shenv.cd = os.chdir
shenv.mkdir = fs.makeDirectory
local function findPath(name)
 path = os.getenv("PATH") or "/boot/exec"
 for l in path:gmatch("[^\n]+") do
  if fs.exists(l.."/"..name) then
   return l.."/"..name
  elseif fs.exists(l.."/"..name..".lua") then
   return l.."/"..name..".lua"
  end
 end
end
setmetatable(shenv,{__index=function(_,k)
 local fp = findPath(k)
 if _G[k] then
  return _G[k]
 elseif fp then
  local rqid = string.format("shell-%d",math.random(1,99999))
  return function(...)
   local tA = {...}
   local pid = os.spawn(function() computer.pushSignal(rqid,pcall(loadfile(fp),table.unpack(tA))) end,fp)
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
   until not os.taskInfo(pid)
  end
 end
end})
print(_VERSION)
os.setenv("run",true)
while os.getenv("run") do
 io.write(string.format("%s:%s> ",os.getenv("HOSTNAME") or "localhost",(os.getenv("PWD") or _VERSION)))
 local input=io.read()
 if input:sub(1,1) == "=" then
  input = "return "..input:sub(2)
 end
 tResult = {pcall(load(input,"shell","t",shenv))}
 if tResult[1] == true then table.remove(tResult,1) end
 for k,v in pairs(tResult) do
  print(v)
 end
end
end))
