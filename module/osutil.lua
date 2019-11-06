function os.chdir(p) -- changes the current working directory of the calling process to the directory specified in *p*, returning true or false, error
 if not (p:sub(1,1) == "/") then
  local np = {}
  for k,v in pairs(fs.segments(os.getenv("PWD").."/"..p)) do
   if v == ".." then
    np[#np] = nil
   else
    np[#np+1] = v
   end
  end
  p = "/"..table.concat(np,"/")
 end
 if fs.exists(p) and fs.list(p) then
  os.setenv("PWD",p)
 else
  return false, "no such directory"
 end
end
