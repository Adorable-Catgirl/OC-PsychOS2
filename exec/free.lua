print("Total  Used  Free")
print(string.format("%4dK %4dK %4dK",computer.totalMemory()/1024,math.floor((computer.totalMemory()-computer.freeMemory())/1024),math.floor(computer.freeMemory()/1024)))
