function loadfile(p) -- reads file *p* and returns a function if possible
 local f = fs.open(p,"rb")
 local c = f:read("*a")
 f:close()
 return load(c,p,"t")
end
function runfile(p,...) -- runs file *p* with arbitrary arguments in the current thread
 return loadfile(p)(...)
end
function spawnfile(p,n) -- spawns a new process from file *p* with name *n*
 return os.spawn(function() print(pcall(loadfile(p))) end,n)
end
function require(f) -- searches for a library with name *f* and returns what the library returns, if possible
 local lib = os.getenv("LIB") or "/boot/lib"
 for d in lib:gmatch("[^\n]+") do
  if fs.exists(d.."/"..f) then
   return runfile(d.."/"..f)
  elseif fs.exists(d.."/"..f..".lua") then
   return runfile(d.."/"..f..".lua")
  end
 end
 error("library not found: "..f)
end
