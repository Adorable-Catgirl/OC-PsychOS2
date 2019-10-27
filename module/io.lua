do
io = {}

function io.close(file)
 return (file or io.output()):close()
end

function io.flush()
 return io.output():flush()
end

function io.lines(filename, ...)
 if filename then
  local file, reason = io.open(filename)
  if not file then
   error(reason, 2)
  end
  local args = table.pack(...)
  return function()
   local result = table.pack(file:read(table.unpack(args, 1, args.n)))
   if not result[1] then
    if result[2] then
     error(result[2], 2)
    else -- eof
     file:close()
     return nil
    end
   end
   return table.unpack(result, 1, result.n)
  end
 else
 return io.input():lines()
 end
end

function io.open(path, mode)
 local stream, result = fs.open(path, mode)
 if stream then
  return buffer.new(mode, stream)
 else
  return nil, result
 end
end

local fdt = {[0]="STDIN","STDOUT","STDERR"}
local function getfh(fd)
 return os.getenv(fdt[fd] or "FILE"..tostring(fd))
end
local function setfh(fd,fh)
 os.setenv(fdt[fd] or "FILE"..tostring(fd),fh)
end

function io.stream(fd,file,mode)
 checkArg(1,fd,'number')
 assert(fd>=0,'fd must be >= 0. 0 is input, 1 is stdout, 2 is stderr')
 if file then
  if type(file) == "string" then
   local result, reason = io.open(file, mode)
   if not result then
    error(reason, 2)
   end
   file = result
  elseif not io.type(file) then
   error("bad argument #1 (string or file expected, got " .. type(file) .. ")", 2)
  end
  setfh(fd,file)
 end
 return getfh(fd)
end

function io.input(file)
 return io.stream(0, file, 'r')
end

function io.output(file)
 return io.stream(1, file,'w')
end

function io.error(file)
 return io.stream(2, file,'w')
end

function io.read(...)
 return io.input():read(...)
end

function io.tmpfile()
 local name = os.tmpname()
 if name then
  return io.open(name, "a")
 end
end

function io.type(object)
 if type(object) == "table" then
  if getmetatable(object) == "file" then
   if object.stream.handle then
    return "file"
   else
    return "closed file"
   end
  end
 end
 return nil
end

function io.write(...)
  return io.output():write(...)
end

function print(...)
 for k,v in ipairs({...}) do
  io.write(tostring(v).."\n")
 end
end
end
