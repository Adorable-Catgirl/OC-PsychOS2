print("PID# VTY# Name")
for k,v in pairs(tTasks) do
 print(string.format("%4d %4d %s",k,v.t or 1,v.n))
end
