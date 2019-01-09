do
_G.fd,_G.io = {},{}
function io.write(d) -- writes *d* to stdout
 fd[os.getenv("t") or 1].write(d)
end
function io.read(d,b) -- reads *d* from stdin, until something is returned, or b is true
 local r = ""
 repeat
  r=fd[os.getenv("t") or 1].read(d)
  coroutine.yield()
 until r or b
 return r
end
function print(...) -- outputs its arguments to stdout, separated by newlines
 for k,v in pairs({...}) do
  io.write(tostring(v).."\n")
 end
end
local function fdw(f,d)
 fd[f.fd].write(d)
end
local function fdr(f,d)
 return fd[f.fd].read(d)
end
local function fdc(f)
 fd[f.fd].close()
 fd[f.fd] = nil
end
function io.newfd() -- creates a new file descriptor and returns it plus its ID
 local nfd=#fd+1
 fd[nfd] = {}
 return nfd,fd[nfd]
end
local function fdfile(f,m) -- create a fd from a file
 local e,fobj = pcall(fs.open,f,m)
 if e and fobj then
  local fdi, fdo =io.newfd()
  if fobj.read then
   function fdo.read(d)
    return fobj:read(d)
   end
  elseif fobj.write then
   function fdo.write(d)
    return fobj:write(d)
   end
  end
  function fdo.close()
   fobj:close()
  end
  return fdi
 end
 return false
end
function io.open(f,m) -- opens file or file descriptor *f* with mode *m*
 if type(f) == "string" then
  f = fdfile(f,m)
 end
 if fd[f] then
  local t = {["close"]=fdc,["read"]=fdr,["write"]=fdw,["fd"]=f,["mode"]=m}
  return t
 end
 return false
end
end
