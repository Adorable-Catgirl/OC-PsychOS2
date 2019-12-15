io = {}
function io.input(fd)
 if type(fd) == "string" then
  fd=fs.open(fd,"rb")
 end
 if fd then
  os.setenv("STDIN",fd)
 end
 return os.getenv("STDIN")
end
function io.output(fd)
 if type(fd) == "string" then
  fd=fs.open(fd,"wb")
 end
 if fd then
  os.setenv("STDOUT",fd)
 end
 return os.getenv("STDOUT")
end

io.open = fs.open

function io.read(...)
 return io.input():read()
end
function io.write(...)
 io.output():write(...)
end

function print(...)
 for k,v in ipairs({...}) do
  io.write(tostring(v).."\n")
 end
end
