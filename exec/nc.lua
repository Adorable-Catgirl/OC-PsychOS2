local minitel = require "minitel"
local tA = {...}

host, port = tA[1], tA[2]

local socket = minitel.open(host,port)
if not socket then return false end
local b = ""
repeat
 io.write(socket:read("*a"))
 coroutine.yield()
 b = io.read(nil,true) or ""
 if b:len() > 0 then
  socket:write(b.."\n")
 end
until socket.state ~= "open"
