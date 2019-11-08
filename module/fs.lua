do
fs = {}
local fsmounts = {}

-- basics
function fs.segments(path) -- splits *path* on each /
 local segments = {}
 for segment in path:gmatch("[^/]+") do
  segments[#segments+1] = segment
 end
 return segments
end
function fs.resolve(path) -- resolves *path* to a specific filesystem mount and path
 if not path or path == "." then path = os.getenv("PWD") end
 if path:sub(1,1) ~= "/" then path=(os.getenv("PWD") or "").."/"..path end
 local segments, rpath, rfs= fs.segments(path)
 local rc = #segments
 dprint(rc)
 for i = #segments, 1, -1 do
  dprint("testing "..table.concat(segments, "/", 1, i),tostring(fsmounts[table.concat(segments, "/", 1, i)]))
  if fsmounts[table.concat(segments, "/", 1, i)] ~= nil then
   dprint("ret",table.concat(segments, "/", 1, i), table.concat(segments, "/", i+1))
   return table.concat(segments, "/", 1, i), table.concat(segments, "/", i+1)
  end
 end
 return "/", table.concat(segments,"/")
end

-- generate some simple functions
for k,v in pairs({"makeDirectory","exists","isDirectory","list","lastModified","remove","size","spaceUsed","spaceTotal","isReadOnly","getLabel"}) do
 fs[v] = function(path)
  local fsi,path = fs.resolve(path)
  return fsmounts[fsi][v](path)
 end
end

local function fread(self,length)
 if length == "*a" then
  length = math.huge
 end
 if type(length) == "number" then
  local rstr, lstr = "", ""
  repeat
   lstr = fsmounts[self.fs].read(self.fid,math.min(2^16,length-rstr:len())) or ""
   rstr = rstr .. lstr
  until rstr:len() == length or lstr == ""
  return rstr
 end
 return fsmounts[self.fs].read(self.fid,length)
end
local function fwrite(self,data)
 fsmounts[self.fs].write(self.fid,data)
end
local function fseek(self,dist)
 fsmounts[self.fs].seek(self.fid,dist)
end
local function fclose(self)
 fsmounts[self.fs].close(self.fid)
end

function fs.open(path,mode) -- opens file *path* with mode *mode*
 mode = mode or "rb"
 local fsi,path = fs.resolve(path)
 if not fsmounts[fsi] then return false end
 local fid = fsmounts[fsi].open(path,mode)
 if fid then
  local fobj = {["fs"]=fsi,["fid"]=fid,["seek"]=fseek,["close"]=fclose}
  if mode:find("r") then
   fobj.read = fread
  end
  if mode:find("w") then
   fobj.write = fwrite
  end
  return fobj
 end
 return false
end

function fs.copy(from,to) -- copies a file from *from* to *to*
 local of = fs.open(from,"rb")
 local df = fs.open(to,"wb")
 if not of or not df then
  return false
 end
 df:write(of:read("*a"))
 df:close()
 of:close()
end

function fs.rename(from,to) -- moves file *from* to *to*
 local ofsi, opath = fs.resolve(from)
 local dfsi, dpath = fs.resolve(to)
 if ofsi == dfsi then
  fsmounts[ofsi].rename(opath,dpath)
  return true
 end
 fs.copy(from,to)
 fs.remove(from)
 return true
end

function fs.mount(path,proxy)
 if fs.isDirectory(path) then
  fsmounts[table.concat(fs.segments(path),"/")] = proxy
  return true
 end
 return false, "path is not a directory"
end

function fs.mounts()
 local rt = {}
 for k,v in pairs(fsmounts) do
  rt[#rt+1] = k,v.address or "unknown"
 end
 return rt
end

function fs.address(path)
 local fsi,_ = fs.resolve(path)
 return fsmounts[fsi].address
end
function fs.type(path)
 local fsi,_ = fs.resolve(path)
 return fsmounts[fsi].type
end

fsmounts["/"] = component.proxy(computer.tmpAddress())
fs.makeDirectory("temp")
if computer.getBootAddress then
 fs.makeDirectory("boot")
 fs.mount("boot",component.proxy(computer.getBootAddress()))
end
for addr, _ in component.list("filesystem") do
 fs.makeDirectory(addr:sub(1,3))
 fs.mount(addr:sub(1,3),component.proxy(addr))
end

end
