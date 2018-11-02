local shenv = {}
setmetatable(shenv,{__index=function(_,k) if _G[k] then return _G[k] elseif fs.exists("/boot/exec/"..k..".lua") then return loadfile("/boot/exec/"..k..".lua") end end})
while true do
 io.write(_VERSION.."> ")
 tResult = {pcall(load(io.read(),"shell","t",shenv))}
 for k,v in pairs(tResult) do
  print(v)
 end
end
