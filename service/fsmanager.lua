while true do
 local tE = {coroutine.yield()}
 if tE[1] == "component_added" and tE[3] == "filesystem" then
  local w, doesExist = pcall(fs.exists,"/"..tE[2]:sub(1,3))
  if not w or not doesExist then
   fs.mounts[tE[2]:sub(1,3)] = component.proxy(tE[2])
  end
 elseif tE[1] == "component_removed" and tE[3] == "filesystem" then
  fs.mounts[tE[2]:sub(1,3)] = nil
 end
end
