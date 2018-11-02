function loadfile(p)
 local f = fs.open(p,"rb")
 local c = f:read("*a")
 f:close()
 return load(c,p,"t")
end
function runfile(p,...)
 loadfile(p)(...)
end
function spawnfile(p,n)
 os.spawn(loadfile(p),n)
end
