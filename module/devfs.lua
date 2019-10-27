devfs = {}
devfs.files = {}
devfs.fds = {}
devfs.nextfd = 0
devfs.component = {}

local function rfalse()
 return false
end
function devfs.component.getLabel()
 return "devfs"
end
devfs.component.spaceUsed, devfs.component.spaceTotal, devfs.component.isReadOnly, devfs.component.isDirectory,devfs.component.size, devfs.component.setLabel = function() return computer.totalMemory()-computer.freeMemory() end, computer.totalMemory, rfalse, rfalse, rfalse, rfalse

function devfs.component.exists(fname)
 return devfs.files[fname] ~= nil
end

function devfs.component.list()
 local t = {}
 for k,v in pairs(devfs.files) do
  t[#t+1] = k
 end
 return t
end

function devfs.component.open(fname, mode)
 fname=fname:gsub("/","")
 if devfs.files[fname] then
  local r,w,c,s = devfs.files[fname](mode)
  devfs.fds[devfs.nextfd] = {["read"]=r or rfalse,["write"]=w or rfalse,["seek"]=s or rfalse,["close"]=c or rfalse}
  devfs.nextfd = devfs.nextfd + 1
  return devfs.nextfd - 1
 end
 return false
end

function devfs.component.read(fd,count)
 if devfs.fds[fd] then
  return devfs.fds[fd].read(count)
 end
end
function devfs.component.write(fd,data)
 if devfs.fds[fd] then
  return devfs.fds[fd].write(data)
 end
end
function devfs.component.close(fd)
 if devfs.fds[fd] then
  devfs.fds[fd].close()
 end
 devfs.fds[fd] = nil
end
function devfs.component.seek(fd,...)
 if devfs.fds[fd] then
  return devfs.fds[fd].seek(...)
 end
end
function devfs.component.remove(fname)
end

function devfs.register(fname,fopen) -- Register a new devfs node with the name *fname* that will run the function *fopen* when opened. This function should return a function for read, a function for write, function for close, and optionally, a function for seek, in that order.
 devfs.files[fname] = fopen
end

fs.mounts.dev = devfs.component

--#include "module/devfs/null.lua"
