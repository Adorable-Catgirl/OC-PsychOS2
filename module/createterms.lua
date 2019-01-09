local ts = {}
for a,_ in component.list("screen") do
 ts[#ts+1] = a
end
for a,_ in component.list("gpu") do
 local r,w = vtemu(a,table.remove(ts,1))
 fd[#fd+1] = {["read"]=r,["write"]=w,["close"]=function() w("\27[2J\27[H") end,["t"]="t"}
end
if #fd < 1 then
 io.open("/boot/console.log","a")
end
