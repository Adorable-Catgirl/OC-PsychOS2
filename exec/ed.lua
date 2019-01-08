local tA = {...}
local fn = tA[1]
local b,C,p = {},{},1
local function sC()
 if p > #b then
  p = #b
 end
 if p < 1 then
  p = 1
 end
end
function C.i()
 p=p-1
 sC()
 while true do
  io.write(tostring(p).."] ")
  l = io.read()
  if l == "." then break end
  table.insert(b,p,l)
  p=p+1
 end
end
function C.l(s,e)
 for i = s or 1, e or #b do
  print(string.format("%4d\t %s",i,b[i]))
 end
end
function C.a()
 p=p+1
 C.i()
end
function C.p(n)
 p=tonumber(n) or p
 sC()
end
function C.d(n)
 n=tonumber(n) or 1
 for i = 1, n do
  print(table.remove(b,p,i))
 end
end
function C.r(f)
 local f = fs.open(f)
 if f then
  for l in f:read("*a"):gmatch("[^\n]+") do
   table.insert(b,p,l)
   p=p+1
  end
  f:close()
 end
end
function C.w(f)
 local f=fs.open(f,"wb")
 if f then
  for _,l in ipairs(b) do
   f:write(l.."\n")
  end
  f:close()
 end
end
if fn then
 C.r(fn)
end
while true do
 io.write("ed> ")
 local l,c = io.read(),{}
 for w in l:gmatch("%S+") do
  c[#c+1] = w
 end
 local e=table.remove(c,1)
 if e == "q" then
  break
 elseif C[e] then
  C[e](table.unpack(c))
 end
end
