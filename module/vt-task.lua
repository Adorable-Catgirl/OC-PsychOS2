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
