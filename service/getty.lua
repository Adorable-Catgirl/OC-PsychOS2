local gpus,screens,ttyn = {}, {}, 0
local function scan()
 local w,di = pcall(computer.getDeviceInfo)
 if w then
  for a,t in pairs(component.list()) do
   if t == "gpu" then
    gpus[a] = gpus[a] or {false, tonumber(di[a].capacity)}
   elseif t == "screen" then
    screens[a] = screens[a] or {false, tonumber(di[a].capacity)}
   end
  end
 else
  dprint("no getDevInfo")
  for a,t in pairs(component.list()) do
   if t == "gpu" then
    gpus[a] = gpus[a] or {false, 8000}
   elseif t == "screen" then
    screens[a] = screens[a] or {false, 8000}
   end
  end
 end
end
local function nextScreen(n)
 local rt = {}
 for k,v in pairs(screens) do
  if not v[1] then
   rt[v[2]] = rt[v[2]] or k
  end
 end
 return rt[n] or rt[8000] or rt[2000] or rt[600]
end
local function allocate()
 for k,v in pairs(gpus) do
  dprint(k)
  local sA = nextScreen(v[2])
  if v[1] == false and sA then
   local r,w = vtemu(k,sA)
   devfs.register("tty"..tostring(ttyn), function() return r,w,function() end end)
   gpus[k][1] = true
   screens[sA][1] = true
   ttyn = ttyn + 1
  end
 end
end
scan()
allocate()
dprint("screens ready")
while true do
 coroutine.yield()
end
