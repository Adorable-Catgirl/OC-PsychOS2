print("PID# VTY# Name")
for k,v in pairs(tTasks) do
 print(string.format("%4d %4d %s",k,v.e.t or 0,v.n))
end
