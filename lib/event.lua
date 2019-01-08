local event = {}
function event.pull(t,...)
 local tA = {...}
 if type(t) == "string" then
  table.insert(tA,1,t)
  t = 0
 end
 if not t or t <= 0 then
  t = math.huge
 end
 local tE = computer.uptime()+t
 repeat
  tEv = {coroutine.yield()}
  local ret = true
  for i = 1, #tA do
   if not (tEv[i] or ""):match(tA[i]) then
    ret = false
   end
  end
  if ret then return table.unpack(tEv) end
 until computer.uptime() > tE
 return nil
end

function event.listen(e,f)
 local op = os.getenv("parent")
 os.setenv("parent",cPid)
 os.spawn(function() while true do
  local tEv = {coroutine.yield()}
  if tEv[1] == e then
   f(table.unpack(tEv))
  end
  if not tTasks[os.getenv("parent")] or (tEv[1] == "unlisten" and tEv[2] == e and tEv[3] == tostring(f)) then break end
 end end,string.format("[%d] %s listener",cPid,e))
 os.setenv("parent",op)
end

function event.ignore(e,f)
 computer.pushSignal("unlisten",e,tostring(f))
end

return event
