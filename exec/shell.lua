local shenv = {}
setmetatable(shenv,{__index=function(_,k) if _G[k] then return _G[k] elseif fs.exists("/boot/exec/"..k..".lua") then return loadfile("/boot/exec/"..k..".lua") end end})
print(_VERSION)
while true do
 io.write((os.getenv("PWD") or _VERSION).."> ")
 tResult = {pcall(load(io.read(),"shell","t",shenv))}
 if tResult[1] == true then table.remove(tResult,1) end
 for k,v in pairs(tResult) do
  print(v)
 end
end
