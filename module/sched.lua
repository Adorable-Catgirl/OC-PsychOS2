tTasks,nPid,nTimeout,cPid = {},1,1,0
function os.spawn(f,n)
 tTasks[nPid] = {["c"]=coroutine.create(f),["n"]=n,["p"]=nPid}
 for k,v in pairs(tTasks[cPid] or {}) do
  tTasks[nPid][k] = tTasks[nPid][k] or v
 end
 nPid = nPid + 1
 return nPid - 1
end
function sched()
 while #tTasks > 0 do
  local tEv = {computer.pullSignal(nTimeout)}
  for k,v in pairs(tTasks) do
   if coroutine.status(v.c) ~= "dead" then
    cPid = k
    coroutine.resume(v.c,table.unpack(tEv))
   else
    tTasks[k] = nil
   end
  end
 end
end
