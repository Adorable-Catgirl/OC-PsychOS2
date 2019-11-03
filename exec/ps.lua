print("PID# Parent | Name")
for k,v in pairs(os.tasks()) do
 local t = os.taskInfo(v)
 print(string.format("%4d   %4d | %s",k,t.parent,t.name))
end
