local counter = 0
for addr in component.list("tape_drive") do
 iofs.register("tape"..tonumber(counter),function()
  local tape = component.proxy(addr)
  return tape.read, tape.write, function() end, tape.seek
 end)
 counter = counter + 1
end
