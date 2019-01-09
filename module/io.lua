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
function io.open(f,m) -- opens file *f* with mode *m*
 local t={["close"]=fdc}
 if type(f) == "string" then
  local e,fobj=pcall(fs.open,f,m)
  if not e then return false, fobj end
  if fobj then
   local fdi,nfd = io.newfd()
   f=fdi
   if fobj.write then
    function nfd.write(d)
     fobj:write(d)
    end
   elseif fobj.read then
    function nfd.read(d)
     return fobj:read(d)
    end
   end
   function nfd.close()
    fobj:close()
   end
  end
 end
 if fd[f].read then
  t.read = fdr
 end
 if fd[f].write then
  t.write = fdw
 end
 t.fd = f
 return t
end
end
do
 local fdi,nfd = io.newfd()
 function nfd.read()
 end
 function nfd.write()
 end
 function nfd.close()
 end
end
