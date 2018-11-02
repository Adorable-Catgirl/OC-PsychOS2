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
function vt100emu(gpu)
 local mx, my = gpu.maxResolution()
 local cx, cy = 1, 1
 local pc = " "
 local lc = ""
 local mode = "n"
 local lw = true
 local sx, sy = 1,1
 local cs = ""

 -- setup
 gpu.setResolution(mx,my)
 gpu.fill(1,1,mx,my," ")

 function termwrite(s)
  s=s:gsub("\8","\27[D")
  pc = gpu.get(cx,cy)
  gpu.setForeground(0xFFFFFF)
  gpu.setBackground(0)
  gpu.set(cx,cy,pc)
  for i = 1, s:len() do
   local cc = s:sub(i,i)

   if mode == "n" then
    if cc == "\n" then -- line feed
     cx, cy = 1, cy+1
    elseif cc == "\r" then -- cursor home
     cx = 1
    elseif cc == "\27" then -- escape
     mode = "e"
    elseif string.byte(cc) > 31 and string.byte(cc) < 127 then -- printable, I guess
     gpu.set(cx, cy, cc)
     cx = cx + 1
    end

   elseif mode == "e" then
    if cc == "[" then
     mode = "v"
     cs = ""
    elseif cc == "D" then -- scroll down
     gpu.copy(1,2,mx,my-1,0,-1)
     gpu.fill(1,my,mx,1," ")
     cy=cy+1
     mode = "n"
    elseif cc == "M" then -- scroll up
     gpu.copy(1,1,mx,my-1,0,1)
     gpu.fill(1,1,mx,1," ")
     mode = "n"
    end

   elseif mode == "v" then -- save cursor
    local n = cs:sub(cs:len(),cs:len())
    if n == "" then n = "\1" end
    if cc == "s" then
     sx, sy = cx, cy
     mode = "n"
    elseif cc == "u" then -- restore cursor
     cx, cy = sx, sy
     mode = "n"
    elseif cc == "H" then -- cursor home or to
     local tx, ty = cs:match("(.);(.)")
     tx, ty = tx or "\1", ty or "\1"
     cx, cy = string.byte(tx), string.byte(ty)
     mode = "n"
    elseif cc == "A" then -- cursor up
     cy = cy - string.byte(n)
     mode = "n"
    elseif cc == "B" then -- cursor down
     cy = cy + string.byte(n)
     mode = "n"
    elseif cc == "C" then -- cursor right
     cx = cx + string.byte(n)
     mode = "n"
    elseif cc == "D" then -- cursor left
     cx = cx - string.byte(n)
     mode = "n"
    elseif cc == "h" and lc == "7" then -- enable line wrap
     lw = true
    elseif cc == "l" and lc == "7" then -- disable line wrap
     lw = false
    end
    cs = cs .. cc
   end

   if cx > mx and lw then
    cx, cy = 1, cy+1
   end
   if cy > my then
    gpu.copy(1,2,mx,my-1,0,-1)
    gpu.fill(1,my,mx,1," ")
    cy=my
   end
   if cy < 1 then cy = 1 end
   if cx < 1 then cx = 1 end

   lc = cc
  end
  pc = gpu.get(cx,cy)
  gpu.setForeground(0)
  gpu.setBackground(0xFFFFFF)
  gpu.set(cx,cy,pc)
  gpu.setForeground(0xFFFFFF)
  gpu.setBackground(0)
 end

 return termwrite
end
fs = {}
fs.mounts = {}

-- basics
function fs.segments(path)
 local segments = {}
 for segment in path:gmatch("[^/]+") do
  segments[#segments+1] = segment
 end
 return segments
end
function fs.resolve(path)
 local segments, rpath = fs.segments(path), "/"
 for i = 2, #segments do
  rpath = rpath .. segments[i] .. "/"
 end
 rpath = rpath:match("(.+)/") or rpath
 return segments[1] or "root",rpath
end

-- generate some simple functions
for k,v in pairs({"makeDirectory","exists","isDirectory","list","lastModified","remove","size","spaceUsed","isReadOnly","getLabel"}) do
 fs[v] = function(path)
  local fsi,path = fs.resolve(path)
  return fs.mounts[fsi][v](path)
 end
end

local function fread(self,length)
 if length == "*a" then
  length = math.huge
 end
 local rstr, lstr = "", ""
 repeat
  lstr = fs.mounts[self.fs].read(self.fid,math.min(2^16,length-rstr:len())) or ""
  rstr = rstr .. lstr
 until rstr:len() == length or lstr == ""
 return rstr
end
local function fwrite(self,data)
 fs.mounts[self.fs].write(self.fid,data)
end
local function fclose(self)
 fs.mounts[self.fs].close(self.fid)
end

function fs.open(path,mode)
 mode = mode or "rb"
 local fsi,path = fs.resolve(path)
 if not fs.mounts[fsi] then return false end
 local fid = fs.mounts[fsi].open(path,mode)
 if fid then
  local fobj = {["fs"]=fsi,["fid"]=fid,["close"]=fclose}
  if mode:sub(1,1) == "r" then
   fobj.read = fread
  else
   fobj.write = fwrite
  end
  return fobj
 end
 return false
end

function fs.copy(from,to)
 local of = fs.open(from,"rb")
 local df = fs.open(to,"wb")
 if not of or not df then
  return false
 end
 df:write(of:read("*a"))
 df:close()
 of:close()
end

function fs.rename(from,to)
 local ofsi, opath = fs.resolve(from)
 local dfsi, dpath = fs.resolve(to)
 if ofsi == dfsi then
  fs.mounts[ofsi].rename(opath,dpath)
  return true
 end
 fs.copy(from,to)
 fs.remove(from)
 return true
end


fs.mounts.temp = component.proxy(computer.tmpAddress())
if computer.getBootAddress then
 fs.mounts.boot = component.proxy(computer.getBootAddress())
end
for addr, _ in component.list("filesystem") do
 fs.mounts[addr:sub(1,3)] = component.proxy(addr)
end

local function rf()
 return false
end
fs.mounts.root = {}

for k,v in pairs(fs.mounts.temp) do
 fs.mounts.root[k] = rf
end
function fs.mounts.root.list()
 local t = {}
 for k,v in pairs(fs.mounts) do
  t[#t+1] = k
 end
 t.n = #t
 return t
end
function fs.mounts.root.isReadOnly()
 return true
end
function loadfile(p)
 local f = fs.open(p,"rb")
 local c = f:read("*a")
 f:close()
 return load(c,p,"t")
end
function runfile(p,...)
 loadfile(p)(...)
end
function spawnfile(p,n)
 os.spawn(loadfile(p),n)
end
function vtemu(gpua,scra)
 local gpu,scr = component.proxy(gpua),component.proxy(scra)
 gpu.bind(scra)
 local write = vt100emu(gpu)
 local kba = {}
 for k,v in ipairs(scr.getKeyboards()) do
  kba[v]=true
 end
 local buf = ""
 os.spawn(function()
  while true do
   local ty,ka,ch = coroutine.yield()
   if ty == "key_down" and kba[ka] then
    if ch == 13 then ch = 10 end
    if ch == 8 and buf:len() > 0 then
     write("\8 \8")
     buf = buf:sub(1,-2)
    elseif ch > 0 then
     write(string.char(ch))
     buf = buf .. string.char(ch)
    end
   end
  end
 end,"keyboard daemon for "..gpua:sub(1,8)..":"..scra:sub(1,8))
 local function read(n)
  n = n or "\n"
  local rdata = ""
  if type(n) == "number" then
   rdata = buf:sub(1,n)
   return rdata
  else
   if n == "*a" then
    rdata = buf
    buf = ""
    return rdata
   end
   local pr,po = buf:match("(.-)"..n.."(.*)")
   buf = po or buf
   return pr
  end
 end
 return read,write
end
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
_G.net={}

do
local modems,packetQueue,packetCache,routeCache,C,Y = {},{},{},{},COMPUTER,UNPACK
net.port,net.hostname,net.route,net.hook,U=4096,computer.address():sub(1,8),true,{},UPTIME

for a in component.list("modem") do
 modems[a] = component.proxy(a)
 modems[a].open(net.port)
end

local function genPacketID()
 local packetID = ""
 for i = 1, 16 do
  packetID = packetID .. string.char(math.random(32,126))
 end
 return packetID
end

local function rawSendPacket(packetID,packetType,to,from,vport,data)
 if routeCache[to] then
  modems[routeCache[to][1]].send(routeCache[to][2],net.port,packetID,packetType,to,from,vport,data)
 else
  for k,v in pairs(modems) do
   v.broadcast(net.port,packetID,packetType,to,from,vport,data)
  end
 end
end

local function sendPacket(packetID,packetType,to,vport,data)
 packetCache[packetID] = computer.uptime()
 rawSendPacket(packetID,packetType,to,net.hostname,vport,data)
end

function net.send(to,vport,data,packetType,packetID)
 packetType,packetID = packetType or 1, packetID or genPacketID()
 packetQueue[packetID] = {packetType,to,vport,data,0}
 sendPacket(packetID,packetType,to,vport,data)
end

local function checkCache(packetID)
 for k,v in pairs(packetCache) do
  if k == packetID then
   return false
  end
 end
 return true
end

os.spawn(function()
 while true do
  local eventTab = {coroutine.yield()}
  if eventTab[1] == "modem_message" and (eventTab[4] == net.port or eventTab[4] == 0) and checkCache(eventTab[6]) then
   for k,v in pairs(packetCache) do
    if computer.uptime() > v+30 then
     packetCache[k] = nil
    end
   end
   for k,v in pairs(routeCache) do
    if computer.uptime() > v[3]+30 then
     routeCache[k] = nil
    end
   end
   routeCache[eventTab[9]] = {eventTab[2],eventTab[3],computer.uptime()}
   if eventTab[8] == net.hostname then
    if eventTab[7] ~= 2 then
     computer.pushSignal("net_msg",eventTab[9],eventTab[10],eventTab[11])
     if eventTab[7] == 1 then
      sendPacket(genPacketID(),2,eventTab[9],eventTab[10],eventTab[6])
     end
    else
     packetQueue[eventTab[11]] = nil
    end
   elseif net.route and checkCache(eventTab[6]) then
    rawSendPacket(eventTab[6],eventTab[7],eventTab[8],eventTab[9],eventTab[10],eventTab[11])
   end
   packetCache[eventTab[6]] = computer.uptime()
  end
  for k,v in pairs(packetQueue) do
   if computer.uptime() > v[5] then
    sendPacket(k,table.unpack(v))
    v[5]=computer.uptime()+30
   end
  end
 end
end,"minitel.3")

end
os.spawn(function() print(pcall(function()
print(_OSVERSION,tostring(computer.totalMemory()/1024).."K memory")
local f = fs.open("/boot/init.txt","rb")
local fc = f:read("*a")
f:close()
for line in fc:gmatch("[^\n]+") do
 print(line)
end
for k,v in pairs(fd) do
 if v.t == "t" then
  tTasks[cPid].t = k
  print("Spawning a shell for terminal #"..tostring(k))
  spawnfile("/boot/exec/shell.lua","shell #"..tostring(k))
 end
end
end)) end,"init")
_OSVERSION="PsychOS 2.0a0"
sched()
