local tA = {...}
local docfiles = {}
for _,file in pairs(tA) do
 docfiles[file] = {}
 local f = io.open(file)
 local lines = {}
 for l in f:read("*a"):gmatch("[^\n]+") do
  if l:find("function") and not l:find("local") then
   lines[#lines+1] = l
  end
 end
 for k,v in pairs(lines) do
  local name, args, desc = v:match("function%s+(.+)%s*%((.*)%)%s*%-%-%s*(.+)")
  if name and args and desc then
   docfiles[file][#docfiles[file]+1] = string.format("##%s(%s)\n%s",name,args,desc)
  end
 end
end

for k,v in pairs(docfiles) do
 if #v > 0 then
  print("#"..k)
  for l,m in pairs(v) do
   print(m)
  end
 end
end
