do
io = {}

function io.type(fh)
 if type(fh) ~= "table" then return nil end
 if fh.state == "open" then
  return "file"
 elseif fh.state == "closed" then
  return "closed file"
 end
 return nil
end

function io.read(buf, n)
 n = n or buf
 buf = buf or io.input()
 print("bread",type(buf),n)
 if not buf.aread then return nil end
 if not buf.abmode then
  buffer.write(buf,buf.fh:read(buf.m - buf.b:len()))
 end
 local rv = buffer.read(buf,n)
 buffer.write(buf,buf.fh:read(buf.m - buf.b:len()))
 return rv
end
function io.write(buf, d)
 d = d or buf
 buf = buf or io.output()
 print("bwrite",type(buf),d)
 if not buf.awrite then return nil end
 if buf.b:len() + d:len() > buf.m then
  buf.fh:write(buffer.read(buf,buf.m))
 end
 local rv = buffer.write(buf,d)
 if not buf.abmode then
  buf.fh:write(buffer.read(buf,buf.m))
 end
 return rv
end

function io.close(fh)
 fh.fh.close()
 fh.state = "closed"
end

function io.flush()
end

function io.open(fname,mode)
 mode=mode or "r"
 local buf = buffer.new()
 buf.fh, er = fs.open(fname,mode)
 if not buf.fh then
  error(er)
 end
 buf.state = "open"
 buf.aread = mode:match("r")
 buf.awrite = mode:match("w") or mode:match("a")
 setmetatable(buf,{__index=io})
 return buf
end

function print(...)
 for k,v in ipairs({...}) do
  io.write(string.format("%s\n",tostring(v)))
 end
end

io.stdin = io.open("/dev/null")
io.stdout = io.open("/dev/null","w")

function io.input(fname)
 if not fname then return os.getenv("STDIN") or io.stdin end
 os.setenv("STDIN",io.open(fname))
end

function io.output(fname)
 if not fname then return os.getenv("STDOUT") or io.stdout end
 os.setenv("STDOUT",io.open(fname,"w"))
end

end
