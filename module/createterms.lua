local ts = {}
for a,_ in component.list("screen") do
 ts[#ts+1] = a
end
local ttyn = 0
for a,_ in component.list("gpu") do
 local r,w = vtemu(a,table.remove(ts,1))
-- fd[#fd+1] = {["read"]=r,["write"]=w,["close"]=function() w("\27[2J\27[H") end,["t"]="t"}
 iofs.register("tty"..tostring(ttyn),function() return r,w,function() w("\27[2J\27[H") end end)
 local f = io.open("/iofs/tty"..tostring(ttyn),"rw")
 fd[f.fd].t = "t"
 ttyn = ttyn + 1
end
do
 iofs.register("syslog",function() return function() return "" end, function(msg) syslog(msg,nil,tTasks[cPid].n) end, function() return true end end)
end
if #fd < 1 then
 io.open("/iofs/syslog","rw")
end
