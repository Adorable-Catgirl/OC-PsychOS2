_G.fd,_G.io = {},{}
do
function io.write(d)
 fd[tTasks[cPid].t or 1].w(d)
end
function io.read(d,b)
 local r = ""
 repeat
  r=fd[tTasks[cPid].t or 1].r(d)
  coroutine.yield()
 until r or b
 return r
end
function print(...)
 for k,v in pairs({...}) do
  io.write(tostring(v).."\n")
 end
end

local ts = {}
for a,_ in component.list("screen") do
 ts[#ts+1] = a
end
for a,_ in component.list("gpu") do
 local r,w = vtemu(a,table.remove(ts,1))
 fd[#fd+1] = {["r"]=r,["w"]=w,["t"]="t"}
end
end
