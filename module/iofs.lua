iofs = {}
iofs.files = {}
iofs.fds = {}
iofs.nextfd = 0
iofs.component = {}

local function rfalse()
 return false
end
function iofs.component.getLabel()
 return "iofs"
end
iofs.component.spaceUsed, iofs.component.spaceTotal, iofs.component.isReadOnly, iofs.component.isDirectory,iofs.component.size, iofs.component.setLabel = function() return computer.totalMemory()-computer.freeMemory() end, computer.totalMemory, rfalse, rfalse, rfalse, rfalse

function iofs.component.exists(fname)
 return iofs.files[fname] ~= nil
end

function iofs.component.list()
 local t = {}
 for k,v in pairs(iofs.files) do
  t[#t+1] = k
 end
 return t
end

function iofs.component.open(fname, mode)
 fname=fname:gsub("/","")
 if iofs.files[fname] then
  local r,w,c,s = iofs.files[fname](mode)
  iofs.fds[iofs.nextfd] = {["read"]=r or rfalse,["write"]=w or rfalse,["seek"]=s or rfalse,["close"]=c or rfalse}
  iofs.nextfd = iofs.nextfd + 1
  return iofs.nextfd - 1
 end
 return false
end

function iofs.component.read(fd,count)
 if iofs.fds[fd] then
  return iofs.fds[fd].read(count)
 end
end
function iofs.component.write(fd,data)
 if iofs.fds[fd] then
  return iofs.fds[fd].write(data)
 end
end
function iofs.component.close(fd)
 if iofs.fds[fd] then
  iofs.fds[fd].close()
 end
 iofs.fds[fd] = nil
end
function iofs.component.seek(fd,...)
 if iofs.fds[fd] then
  return iofs.fds[fd].seek(...)
 end
end

function iofs.register(fname,fopen) -- Register a new iofs node with the name *fname* that will run the function *fopen* when opened. This function should return a function for read, a function for write, and a function for close, in that order.
 iofs.files[fname] = fopen
end

fs.mounts.iofs = iofs.component
